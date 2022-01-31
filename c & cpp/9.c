#include<stdio.h>
int cells[100];

int n = 4;
int rt=0;
int tmp1;
int tmp2;

void solve(int t){
    int i;
    for(i=t+1;i<n;i++){
        tmp1 = cells[i]-cells[t];
        tmp2 = i-t;
        if(tmp1<=0) tmp1*=-1;
        if(tmp1==0) return;
        if(tmp1==tmp2) return;
    }
    if(t==0){
        rt+=1;
        return;
    }
    for(i=0;i<n;i++){
        cells[t-1]=i;
        solve(t-1);
    }
}
int main(){
    solve(n);
    printf("%d", rt);
}
