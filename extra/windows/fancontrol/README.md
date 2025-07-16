# FanControl

FanControl is a hardware fan control application. It's not installed by default
with chezmoi because not all systems need it.

## Usage

1. Install FanControl with winget:

   ```pwsh
   winget install --id Rem0o.FanControl --exact
   ```

   (It would be prudent, however, to check that the
   [FanControl GitHub Page](https://github.com/Rem0o/FanControl.Releases) agrees
   with this package ID.)

2. Place a copy of one of the JSON configuration files in this directory into
   the FanControl configuration directory, which is usually located at:
   `%PROGRAMFILES(X86)%\FanControl\Configurations\`.

3. Open FanControl, click the 3 dots in the top right corner, and select "Load
   Configuration". Choose the configuration file you placed in the previous
   step.

4. To run FanControl at startup, create a task in the Task Scheduler to run the
   FanControl executable at logon. (Startup folder method doesn't work.):

   - General:
     - Name: FanControl
     - Run whether user is logged on or not
     - Run with highest privileges
   - Triggers:
     - At log on
   - Actions:
     - Start a program
       - Program/script: `C:\Program Files (x86)\FanControl\FanControl.exe`
       - Start in: `C:\Program Files (x86)\FanControl\`
