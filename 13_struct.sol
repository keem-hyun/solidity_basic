// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Test {
    struct Book {
        string title;
        string author;
        uint book_id;
    }

    Book book;

    function setBook() public {
        book = Book("Learn solidity", "TP", 1);
    }

    function getBook() public view returns (Book memory) {
        return book;
    }

    function getTitle() public view returns (string memory) {
        return book.title;
    }

    function getAuthor() public view returns (string memory) {
        return book.author;
    }

    function getBookId() public view returns (uint) {
        return book.book_id;
    }
}
