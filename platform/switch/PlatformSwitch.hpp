#pragma once

#ifdef __SWITCH__
namespace PlatformSwitch
{
    // Finds the game data folder (see PlatformSwitch.cpp) and makes it the
    // working directory; argv[0] is the NRO path hbmenu passes.
    void Init(int argc, char **argv);
    void Shutdown();
    bool ShouldKeepRunning();
}
#endif
