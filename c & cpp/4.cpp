#include<bits/stdc++.h>

using namespace std;

//--------- Rules -------------
// E: Any expression
// MD: Expression that is not splitted by + or -
// CR: Expression that is not splitted at all
// N : number
// E -> MD + E
// E -> MD - E
// E -> MD
// MD -> MD * CR
// MD -> MD / CR
// MD -> CR
// CR -> (CR)
// CR -> N
// N -> [0-9]
// N -> [0-9]N
//---------------------------

// this does not catch overflow

char cr;

void get() {
    do {
        cr = getchar();
    } while(cr == ' ');
}


int read_expr();
int read_md();
int read_number();
int read_cr();

int read_number() {
    int x = 0;
    while('0' <= cr && cr <= '9') {
        x = 10 * x + (cr - '0');
        cr = getchar();        
    }
    if(cr == ' ')
        get();
    return x;
}
int read_cr() {
    if(cr == '(') {
        get();
        int x = read_expr();
        if(cr != ')')
            throw "invalid expression";
        get();
        return x;
    } else if('0' <= cr && cr <= '9') {
        return read_number();
    }
    throw "invalid expression";
}
int read_md() {
    int x = read_cr();
    while(cr == '*' || cr == '/') {
        if(cr == '*') {
            get();
            x = x * read_cr();
        } else if(cr == '/') {
            get();
            x = x / read_cr();
        }
    }
    return x;
}
int read_expr() {
    int x = read_md();
    if(cr == '+') {
        get();
        return x + read_expr();
    }
    if(cr == '-') {
        get();
        return x - read_expr();
    }
    return x;
}


int main() {
    try {
        get();
        cout << read_expr() << "\n";
        if(cr != '\n')
            throw "expression is not valid";
    } catch(string s) {
        cout << s << "\n";
    }
    return 0;
}