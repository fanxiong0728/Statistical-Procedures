
/*Source: 
Generalizing Google’s PageRank to Rank National Football League Teams
Written By: Anjela Y. Govan; Carl D. Meyer; Russell Albright
Avalible at: http://www2.sas.com/proceedings/forum2008/151-2008.pdf*/

/*For more information on this SAS program and Google Page Rank implementation in SAS/IML, 
please see: https://pdfs.semanticscholar.org/presentation/e8b6/9238a877e2f996f56b34cdf271e58141bd1d.pdf */

/*Example Data*/

data indexTeam;
Input Team $3. Index;
datalines;
Car 1
Dal 2
Hou 3
NO 4
Phi 5
Was 6
;
run;

data NFL2007EXAMPLE;
Input Team_A_Index Score_A Team_B_Index Score_B;
datalines;
1 16 4 13
2 38 5 17
2 28 6 23
3 34 1 21
3 23 4 10
4 31 1 6
5 33 6 25
5 38 4 23
6 27 2 6
6 20 5 12
;
run;

/*IML framework for Ranking Modules*/
proc iml;

/*placeholder for the GeM Module*/
/****************************************************************
Module GeM -computes rating scores of the teams
INPUT: A (games by 4) matrix [team i score i team j score j]
alpha - contribution of scores to the ratings
teams - number of teams
OUTPUT: vector Gvec, Gvec(i)=rating score of team i
*****************************************************************/
start GeM(A,alpha,teams); /* begin module GeM*/
M=j(teams,teams,0);
do i=1 to nrow(A);
if A[i,2]>A[i,4] then M[A[i,3], A[i,1]]=A[i,2]-A[i,4];
else M[A[i,1], A[i,3]]=A[i,4]-A[i,2];
end;
rowsuma = M[ ,+];
/* Initialize the adjusting matrices a and b; matrix a will rescale
the nonzero rows of M, and matrix b will replace the zero rows.*/
ae=rowsuma[1];
if ae^=0 then
do; ae=1/ae; a=j(1,teams,ae); b=j(1,teams,0); end;
else
do; a=j(1,teams,1); b=j(1,teams,1/teams); end;
/* Finish constructing the adjustment matrices.*/
x=1;
do while(x<teams);
x=x+1; ae=rowsuma[x];
if ae^=0 then
do;
ae=1/ae; atemp=j(1,teams,ae); a=a//atemp;
btemp=j(1,teams,0); b=b//btemp;
end;
else
do;
atemp=j(1,teams,1); a=a//atemp;
btemp=j(1,teams,1/teams); b=b//btemp;
end;
end;
/* Stochastic matrix S is formed as S=M#A, element-wise multiplication
of the given matrix. This makes non zero rows add to 1. Then add matrix
b to S to replace the zero rows.*/
S=M#a;
S=S+b;
/* Form matrix G */
G=alpha*S+(1-alpha)*j(teams,1,1/teams)*j(1,teams,1);
call eigen(E,V,t(G));
/*Extract the eigenvector (column of V) corresponding to the
eigenvalue 1 (1+0i) in the matrix E. */
t=0;
do i=1 to teams;
if abs(E[i,1]-1)<0.0000001 then t=i;
end;
Gvec = V[ ,t];
Gvec=abs(Gvec); Gvec=(1/sum(Gvec))*Gvec;
return(Gvec);
finish; /* end module GeM*/

use NFL2007EXAMPLE;
read all into A;

close NFL2007EXAMPLE;
dim=max(max(A[,1]),max(A[,3]));
GeMrating=GeM(A,0.85,dim); /*call function GeM(data matrix, number of teams)*/

create result07 var{GeMrating};
append;
show contents;
quit;
