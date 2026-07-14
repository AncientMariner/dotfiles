#include <windows.h>
#include <stdio.h>
#include <string.h>
#include <wchar.h>

#define MAX_DEPTH_DEFAULT 100

static HANDLE outHandle;
static int showHidden;

void writeUTF8(const wchar_t *ws) {
    if (!ws || ws[0] == L'\0') return;
    int len = WideCharToMultiByte(CP_UTF8, 0, ws, -1, NULL, 0, NULL, NULL);
    if (len <= 1) return;
    char *buf = (char *)HeapAlloc(GetProcessHeap(), 0, len);
    if (!buf) return;
    WideCharToMultiByte(CP_UTF8, 0, ws, -1, buf, len, NULL, NULL);
    DWORD written;
    WriteFile(outHandle, buf, len - 1, &written, NULL);
    HeapFree(GetProcessHeap(), 0, buf);
}

void writeLine(const wchar_t *prefix, const wchar_t *connector, const wchar_t *name, int isDir) {
    wchar_t line[MAX_PATH * 3];
    if (isDir)
        _snwprintf(line, MAX_PATH * 3, L"%s%s%s/\n", prefix, connector, name);
    else
        _snwprintf(line, MAX_PATH * 3, L"%s%s%s\n", prefix, connector, name);
    writeUTF8(line);
}

void enableBackupPrivilege() {
    HANDLE token;
    TOKEN_PRIVILEGES tp;
    LUID luid;

    if (!OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &token))
        return;
    if (!LookupPrivilegeValueW(NULL, SE_BACKUP_NAME, &luid)) {
        CloseHandle(token);
        return;
    }
    tp.PrivilegeCount = 1;
    tp.Privileges[0].Luid = luid;
    tp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
    AdjustTokenPrivileges(token, FALSE, &tp, sizeof(tp), NULL, NULL);
    CloseHandle(token);
}

void walk(const wchar_t *dir, const wchar_t *prefix, int maxDepth, int currentDepth) {
    if (currentDepth > maxDepth)
        return;

    wchar_t searchPath[MAX_PATH];
    // strip trailing backslash to avoid double \\ in search path
    wchar_t cleanDir[MAX_PATH];
    wcsncpy(cleanDir, dir, MAX_PATH - 1);
    cleanDir[MAX_PATH - 1] = L'\0';
    int dirLen = (int)wcslen(cleanDir);
    while (dirLen > 1 && (cleanDir[dirLen - 1] == L'\\' || cleanDir[dirLen - 1] == L'/'))
        cleanDir[--dirLen] = L'\0';
    _snwprintf(searchPath, MAX_PATH, L"%s\\*", cleanDir);

    WIN32_FIND_DATAW ffd;
    HANDLE hFind = FindFirstFileExW(
        searchPath,
        FindExInfoBasic,
        &ffd,
        FindExSearchNameMatch,
        NULL,
        FIND_FIRST_EX_LARGE_FETCH
    );

    if (hFind == INVALID_HANDLE_VALUE) {
        if (GetLastError() == ERROR_ACCESS_DENIED) {
            wchar_t line[MAX_PATH];
            _snwprintf(line, MAX_PATH, L"%s[permission denied]\n", prefix);
            writeUTF8(line);
        }
        return;
    }

    wchar_t entries[4096][MAX_PATH];
    DWORD attrs[4096];
    int count = 0;

    do {
        if (wcscmp(ffd.cFileName, L".") == 0 || wcscmp(ffd.cFileName, L"..") == 0)
            continue;
        if (!showHidden && ffd.cFileName[0] == L'.')
            continue;
        if (count < 4096) {
            wcsncpy(entries[count], ffd.cFileName, MAX_PATH - 1);
            entries[count][MAX_PATH - 1] = L'\0';
            attrs[count] = ffd.dwFileAttributes;
            count++;
        }
    } while (FindNextFileW(hFind, &ffd));

    FindClose(hFind);

    for (int i = 0; i < count; i++) {
        int isLast = (i == count - 1);
        int isDir  = (attrs[i] & FILE_ATTRIBUTE_DIRECTORY) != 0;

        const wchar_t *connector   = isLast ? L"└── " : L"├── ";
        const wchar_t *childSuffix = isLast ? L"    " : L"│   ";

        writeLine(prefix, connector, entries[i], isDir);

        if (isDir) {
            wchar_t childDir[MAX_PATH];
            _snwprintf(childDir, MAX_PATH, L"%s\\%s", cleanDir, entries[i]);

            wchar_t childPrefix[MAX_PATH];
            _snwprintf(childPrefix, MAX_PATH, L"%s%s", prefix, childSuffix);

            walk(childDir, childPrefix, maxDepth, currentDepth + 1);
        }
    }
}

int wmain(int argc, wchar_t *argv[]) {
    wchar_t *folder = NULL;
    int maxDepth = MAX_DEPTH_DEFAULT;
    showHidden = 0;

    for (int i = 1; i < argc; i++) {
        if (wcscmp(argv[i], L"--hidden") == 0) {
            showHidden = 1;
        } else if (wcscmp(argv[i], L"--depth") == 0 && i + 1 < argc) {
            maxDepth = _wtoi(argv[++i]);
        } else if (argv[i][0] != L'-') {
            folder = argv[i];
        }
    }

    if (!folder) {
        wprintf(L"usage: fstree <folder> [--depth N] [--hidden]\n");
        return 1;
    }

    DWORD attr = GetFileAttributesW(folder);
    if (attr == INVALID_FILE_ATTRIBUTES) {
        wprintf(L"error: cannot access \"%s\"\n", folder);
        return 1;
    }
    if (!(attr & FILE_ATTRIBUTE_DIRECTORY)) {
        wprintf(L"error: \"%s\" is not a directory\n", folder);
        return 1;
    }

    enableBackupPrivilege();

    outHandle = CreateFileW(
        L"tree_structure.txt",
        GENERIC_WRITE,
        0,
        NULL,
        CREATE_ALWAYS,
        FILE_ATTRIBUTE_NORMAL,
        NULL
    );

    if (outHandle == INVALID_HANDLE_VALUE) {
        wprintf(L"error: cannot write tree_structure.txt (error %lu)\n", GetLastError());
        return 1;
    }

    // write UTF-8 BOM
    DWORD written;
    WriteFile(outHandle, "\xEF\xBB\xBF", 3, &written, NULL);

    // strip trailing slashes for display (e.g. "E:\" -> "E:")
    wchar_t rootName[MAX_PATH];
    wcsncpy(rootName, folder, MAX_PATH - 1);
    rootName[MAX_PATH - 1] = L'\0';
    int rootLen = (int)wcslen(rootName);
    while (rootLen > 1 && (rootName[rootLen - 1] == L'\\' || rootName[rootLen - 1] == L'/'))
        rootName[--rootLen] = L'\0';
    wchar_t rootLine[MAX_PATH];
    _snwprintf(rootLine, MAX_PATH, L"%s/\n", rootName);
    writeUTF8(rootLine);

    walk(folder, L"", maxDepth, 1);

    CloseHandle(outHandle);
    wprintf(L"tree_structure.txt written\n");
    return 0;
}
