#include<bits/stdc++.h>

using namespace std;

int f(int n) {
    if(n == 1)
        return 1;        
    if(n & 1) {
        return 2 * f(n/2) + 1;
    } else {
        return 2 * f(n/2) - 1;
    }
}

int main() {
    int n;
    cin >> n;
    cout << f(n) << endl;
}