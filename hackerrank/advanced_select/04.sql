/*
Binary Tree Nodes

You are given a table, BST, containing two columns: N and P, where N represents the value of a node in Binary Tree, and P is the parent of N.

Write a query to find the node type of Binary Tree ordered by the value of the node. Output one of the following for each node:
Root: If node is root node.
Leaf: If node is leaf node.
Inner: If node is neither root nor leaf node.
*/

select
    n,
    case
        when p is null then 'root'
        when n not in (select p from bst where p is not null) then 'leaf'
        else 'inner'
    end as node_type
from bst
order by n;