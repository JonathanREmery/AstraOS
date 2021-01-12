static char* VIDEO_MEMORY = 0;
static int cursorPos[2] = {0,0};

void main() {
    VIDEO_MEMORY = (char*)0xb8000;
    *(char*)(VIDEO_MEMORY) = 0x41;
    *(char*)(VIDEO_MEMORY+1) = 0x0f;
    cursorPos[0] = 0xb8000;
    cursorPos[1] = 0;
    char* asciiArt = "               _              ____   _____ \n     /\\       | |            / __ \\ / ____|\n    /  \\   ___| |_ _ __ __ _| |  | | (___  \n   / /\\ \\ / __| __| '__/ _` | |  | |\\___ \\ \n  / ____ \\\\__ \\ |_| | | (_| | |__| |____) |\n /_/    \\_\\___/\\__|_|  \\__,_|\\____/|_____/ \n";

    print(asciiArt);
}

void printChar(char c) {
    if (c == 10) {
        setXCursorPos(0);
        incrementYCursorPos();
        return;
    }
    *(VIDEO_MEMORY+(cursorPos[0]*2)+(cursorPos[1]*160))   = c;
    *(VIDEO_MEMORY+(cursorPos[0]*2)+(cursorPos[1]*160)+1) = 0x0f;
}

void print(char* str) {
    int i = 0;
    while (1) {
        char c = *(str+i);
        if (c == 0) {
            break;
        }
        printChar(c);
        if (c != 10) { 
            incrementXCursorPos();
        }
        i++;
    }
}

void incrementXCursorPos() {
    cursorPos[0]++;
}

void incrementYCursorPos() {
    cursorPos[1]++;
}

void setXCursorPos(int x) {
    cursorPos[0] = x;
}

void setYCursorPos(int y) {
    cursorPos[1] = y;
}
