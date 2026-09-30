#ifdef __SWITCH__

#include <switch.h>
#include <unistd.h>
#include <sys/stat.h>
#include <cerrno>
#include <cstdio>
#include <cstring>
#include <dirent.h>
#include <string>
#include <vector>

extern "C" {
    u32 __nx_applet_type = AppletType_Default;
    void userAppInit(void) {}
    void userAppExit(void) {}
}

namespace PlatformSwitch
{

static bool s_socketsUp = false;
static bool s_romfsUp   = false;

// A folder holds the game when its CM.DAT is there, under any of the names the
// file loader accepts (FAT is case-insensitive, so cm.dat matches too).
static bool HasGameData(const std::string &dir)
{
    struct stat st;
    for (const char *name : {"CM.DAT", "\xE7\xB4\x85\xE9\xAD\x94\xE9\x83\xB7" "CM.DAT", "KOUMAKYO_CM.DAT"})
        if (stat((dir + "/" + name).c_str(), &st) == 0)
            return true;
    return false;
}

// The NRO's own folder first (argv[0], then the working directory hbmenu
// sets), then th06 / touhou6 folders directly on the SD card, in switch/, in
// a shared touhou/ or switch/touhou/ folder, or in games/ and roms/. The
// folder found becomes the working directory, which all game paths use.
static void LocateGameData(int argc, char **argv)
{
    std::vector<std::string> candidates;
    if (argc > 0 && argv && argv[0]) {
        std::string nro = argv[0];
        const size_t slash = nro.find_last_of('/');
        if (slash != std::string::npos)
            candidates.push_back(nro.substr(0, slash));
    }
    char cwd[FS_MAX_PATH];
    if (getcwd(cwd, sizeof(cwd)))
        candidates.push_back(cwd);
    for (const char *root : {"sdmc:/switch/", "sdmc:/", "sdmc:/touhou/", "sdmc:/switch/touhou/", "sdmc:/games/", "sdmc:/roms/"})
        for (const char *name : {"th06", "touhou6", "touhou06", "touhou 6"})
            candidates.push_back(std::string(root) + name);
    for (const std::string &dir : candidates) {
        if (HasGameData(dir)) {
            chdir(dir.c_str());
            std::printf("data folder: %s\n", dir.c_str());
            return;
        }
    }
    std::printf("data folder: not found, staying in the launch folder\n");
}

void Init(int argc, char **argv)
{
    if (R_SUCCEEDED(socketInitializeDefault())) {
        s_socketsUp = true;
        nxlinkStdio();
    }

    std::printf("\n=== th06-switch bring-up ===\n");

    Result rc = romfsInit();
    if (R_SUCCEEDED(rc)) {
        s_romfsUp = true;
        std::printf("romfs OK\n");
    }

    LocateGameData(argc, argv);

    if (DIR *d = opendir(".")) {
        std::printf("cwd listing:\n");
        int n = 0;
        struct dirent *e;
        while ((e = readdir(d)) && n < 20) {
            std::printf("  %s\n", e->d_name);
            n++;
        }
        closedir(d);
    }
}

void Shutdown()
{
    if (s_romfsUp)   { romfsExit();  s_romfsUp = false; }
    if (s_socketsUp) { socketExit(); s_socketsUp = false; }
}

bool ShouldKeepRunning()
{
    return appletMainLoop();
}

} // namespace PlatformSwitch

#endif // __SWITCH__
