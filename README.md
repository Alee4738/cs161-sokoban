# cs161-sokoban
A solver for the Japanese puzzle game [sokoban](https://en.wikipedia.org/wiki/Sokoban).
This project was done for the UCLA course CS 161: Foundations of Artificial Intellgience.

## Learning Accomplishments
* How to implement a successor function
* How to write a good heuristic function with optimizations
* Practice with Test Driven Development (TDD)
* Lisp practice
* Programming design practice

## Introduction
Sokoban is a one-player puzzle game where the user controls a single character on a map of walls, boxes, and goals.
The objective of the game is to push all boxes onto goals.

This solver uses a given search engine (A* search) to find the smallest number of steps needed to solve the puzzle and
returns those steps in sequence.

## File Structure
* a-star.lsp - a given search engine (I did not write this) that uses [A* search](http://web.mit.edu/eranki/www/tutorials/search/)
to look for a solution in a tree of possible states (which I did write)
* hw3.lsp - the main file that implements the successor function, heuristic function, goal state, etc.
* t-hw3.lsp - a file of test cases for hw3.lsp
* spec.pdf - the specification of the assignment
