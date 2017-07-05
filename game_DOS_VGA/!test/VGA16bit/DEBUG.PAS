    else if (u<>0) and (d<>0) and (l=0)  and (r=0)  then maze[z]:=2

    else if (u<>0) and (r<>0) and (l=0)  and (d=0)  then maze[z]:=3
    else if (l<>0) and (u<>0) and (r=0)  and (d=0)  then maze[z]:=4
    else if (l<>0) and (d<>0) and (u=0)  and (r=0)  then maze[z]:=5
    else if (d<>0) and (r<>0) and (l=0)  and (u=0)  then maze[z]:=6

    else if (r=0) and (l=0) and (u=0) and (d<>0) then maze[z]:=7
    else if (r=0) and (l=0) and (d=0) and (u<>0) then maze[z]:=8
    else if (u=0) and (d=0) and (r=0) and (l<>0) then maze[z]:=9
    else if (u=0) and (d=0) and (l=0) and (r<>0) then maze[z]:=10

    else if (u<>0) and (d=0 ) and (l<>0) and (r<>0) then maze[z]:=12
    else if (u=0)  and (d<>0) and (l<>0) and (r<>0) then maze[z]:=13
    else if (u<>0) and (d<>0) and (l=0)  and (r<>0) then maze[z]:=14
    else if (u<>0) and (d<>0) and (l<>0) and (r=0 ) then maze[z]:=15
    else if (u<>0) and (d<>0) and (l<>0) and (r<>0) then maze[z]:=11
    else maze[z]:=16;
