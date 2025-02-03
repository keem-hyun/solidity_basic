// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function transfer(address, uint256) external returns (bool); // ERC20 토큰 전송 함수
    function transferFrom(address, address, uint256) external returns (bool); // ERC20 토큰을 특정 주소에서 전송하는 함수
}

contract CrowdFund {
    // 이벤트 선언
    event Launch(
        uint256 id,
        address indexed creator,
        uint256 goal,
        uint32 startAt,
        uint32 endAt
    );
    event Cancel(uint256 id); // 캠페인 취소 이벤트
    event Pledge(uint256 indexed id, address indexed caller, uint256 amount); // 기부 이벤트
    event Unpledge(uint256 indexed id, address indexed caller, uint256 amount); // 기부 취소 이벤트
    event Claim(uint256 id); // 캠페인 성공 후 자금 인출 이벤트
    event Refund(uint256 id, address indexed caller, uint256 amount); // 목표 미달성 시 환불 이벤트

    // 캠페인 구조체 정의
    struct Campaign {
        address creator; // 캠페인 생성자
        uint256 goal; // 목표 금액
        uint256 pledged; // 현재까지 기부된 금액
        uint32 startAt; // 캠페인 시작 시간
        uint32 endAt; // 캠페인 종료 시간
        bool claimed; // 캠페인 성공 후 자금이 인출되었는지 여부
    }

    IERC20 public immutable token; // 사용할 ERC20 토큰
    uint256 public count; // 캠페인 수
    mapping(uint256 => Campaign) public campaigns; // 캠페인 ID에서 캠페인 정보로의 매핑
    mapping(uint256 => mapping(address => uint256)) public pledgedAmount; // 캠페인 ID와 사용자 주소에서 기부 금액으로의 매핑

    // 생성자 함수: ERC20 토큰의 주소를 초기화
    constructor(address _token) {
        token = IERC20(_token);
    }

    // 새로운 캠페인을 시작하는 함수
    function launch(uint256 _goal, uint32 _startAt, uint32 _endAt) external {
        require(_startAt >= block.timestamp, "start at < now"); // 시작 시간이 현재 시간보다 늦어야 함
        require(_endAt >= _startAt, "end at < start at"); // 종료 시간이 시작 시간보다 늦어야 함
        require(_endAt <= block.timestamp + 90 days, "end at > max duration"); // 캠페인 기간이 최대 90일을 초과할 수 없음

        count += 1; // 캠페인 수 증가
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });

        emit Launch(count, msg.sender, _goal, _startAt, _endAt); // 캠페인 시작 이벤트 발생
    }

    // 캠페인을 취소하는 함수
    function cancel(uint256 _id) external {
        Campaign memory campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "not creator"); // 캠페인 생성자만 취소 가능
        require(block.timestamp < campaign.startAt, "started"); // 캠페인이 시작되기 전에만 취소 가능

        delete campaigns[_id]; // 캠페인 정보 삭제
        emit Cancel(_id); // 캠페인 취소 이벤트 발생
    }

    // 캠페인에 기부하는 함수
    function pledge(uint256 _id, uint256 _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "not started"); // 캠페인이 시작되었는지 확인
        require(block.timestamp <= campaign.endAt, "ended"); // 캠페인이 종료되지 않았는지 확인

        campaign.pledged += _amount; // 기부 금액 추가
        pledgedAmount[_id][msg.sender] += _amount; // 기부자의 기부 금액 업데이트
        token.transferFrom(msg.sender, address(this), _amount); // 기부 금액을 컨트랙트로 전송

        emit Pledge(_id, msg.sender, _amount); // 기부 이벤트 발생
    }

    // 캠페인에서 기부를 취소하는 함수
    function unpledge(uint256 _id, uint256 _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp <= campaign.endAt, "ended"); // 캠페인이 종료되지 않았는지 확인

        campaign.pledged -= _amount; // 기부 금액 차감
        pledgedAmount[_id][msg.sender] -= _amount; // 기부자의 기부 금액 업데이트
        token.transfer(msg.sender, _amount); // 기부 금액 반환

        emit Unpledge(_id, msg.sender, _amount); // 기부 취소 이벤트 발생
    }

    // 캠페인 목표 달성 시 자금을 인출하는 함수
    function claim(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "not creator"); // 캠페인 생성자만 인출 가능
        require(block.timestamp > campaign.endAt, "not ended"); // 캠페인이 종료되었는지 확인
        require(campaign.pledged >= campaign.goal, "pledged < goal"); // 목표 금액 달성 여부 확인
        require(!campaign.claimed, "claimed"); // 이미 인출되었는지 확인

        campaign.claimed = true; // 인출 상태로 변경
        token.transfer(campaign.creator, campaign.pledged); // 기부 금액 인출

        emit Claim(_id); // 자금 인출 이벤트 발생
    }

    // 캠페인이 목표 금액을 달성하지 못한 경우 환불하는 함수
    function refund(uint256 _id) external {
        Campaign memory campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "not ended"); // 캠페인이 종료되었는지 확인
        require(campaign.pledged < campaign.goal, "pledged >= goal"); // 목표 금액 미달성 여부 확인

        uint256 bal = pledgedAmount[_id][msg.sender]; // 기부자의 기부 금액 저장
        pledgedAmount[_id][msg.sender] = 0; // 기부 금액 초기화
        token.transfer(msg.sender, bal); // 기부 금액 반환

        emit Refund(_id, msg.sender, bal); // 환불 이벤트 발생
    }
}

contract ERC20 {
    // 토큰의 이름
    string public name = "Example Token";
    // 토큰의 심볼
    string public symbol = "EXT";
    // 소수점 자리수
    uint8 public decimals = 18;
    // 총 발행량
    uint256 public totalSupply = 1000000 * 10**uint256(decimals);
    // 각 주소의 잔액을 저장하는 매핑
    mapping(address => uint256) public balanceOf;
    // 각 주소가 다른 주소에 대해 허용한 토큰 수를 저장하는 매핑
    mapping(address => mapping(address => uint256)) public allowance;

    // 토큰 전송 이벤트
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 승인 이벤트
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 컨트랙트 생성자
    constructor() {
        // 컨트랙트 배포자에게 총 발행량을 할당
        balanceOf[msg.sender] = totalSupply;
    }

    // 토큰 전송 함수
    function transfer(address to, uint256 value) public returns (bool) {
        // 전송하는 주소의 잔액이 충분한지 확인
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        // 잔액 차감 및 수신자에게 추가
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        // 전송 이벤트 발생
        emit Transfer(msg.sender, to, value);
        return true;
    }

    // 토큰 사용 승인 함수
    function approve(address spender, uint256 value) public returns (bool) {
        // 승인된 토큰 수 설정
        allowance[msg.sender][spender] = value;
        // 승인 이벤트 발생
        emit Approval(msg.sender, spender, value);
        return true;
    }

    // 승인된 토큰 전송 함수
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        // 전송하려는 주소의 잔액이 충분한지 확인
        require(balanceOf[from] >= value, "Insufficient balance");
        // 호출자가 승인된 토큰 수 내에서 전송하려는지 확인
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");
        // 잔액 차감 및 수신자에게 추가
        balanceOf[from] -= value;
        balanceOf[to] += value;
        // 사용된 토큰 수만큼 승인된 양 차감
        allowance[from][msg.sender] -= value;
        // 전송 이벤트 발생
        emit Transfer(from, to, value);
        return true;
    }
}