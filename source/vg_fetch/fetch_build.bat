@echo off

set DefaultIncludeDirectory=..\include\
set DefaultLibDirectory=..\lib\
set DefaultBuildDirectory=..\..\source\vg_fetch\build\
set DefaultSourceDirectory=..\

IF NOT DEFINED clset (call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" x64)

:: docs.microsoft.com/en-us/cpp/build/reference/compiler-options-listed-by-category?view=vs-2019

set SmallCode=-O1
set FastCode=-O2
set FavorSmallCode=-Os
set FavorFastCode=-Ot

set DisableOptimizations=-Od
set GenerateIntrinsics=-Oi
set CompleteDebugInformation=-Zi
set ConcurrentBuild=-MP

set MultithreadExec=-MT
set MultithreadExecDebug=-MTd
set MultithreadDLL=-MD
set MultithreadDebugDLL=-MDd
set DynamicLinkLibrary=-LD

set ExceptionHandling=-EHa

set NoLogo=-nologo
set WarningLevelStrict=-W4
set WarningLevelHarsh=-W3
set WarningLevelSignificant=-W2
set WarningLevelRelaxed=-W1
set WarningAsError=-WX
set DisableAllWarning=-w
set GenerateVersion7Debugging=-Z7
set StructMemberAlignment=-Zp16 

set DisableUnreferencedFormalParam=-wd4100
set DisableConditionalExpressionIsConstant=-wd4127
set DisableInitializedButNotReferenced=-wd4189
set DisableNamelessUnions=-wd4201
set DisableCastOfGreaterSize=-wd4306

set DefaultDisabledWarnings=%DisableUnreferencedFormalParam% %DisableConditionalExpressionIsConstant% %DisableInitializedButNotReferenced% %DisableNamelessUnions% %DisableCastOfGreaterSize%

set DefaultCompilerFlags=%DefaultDisabledWarnings% %NoLogo% %FavorFastCode% %ExceptionHandling% %GenerateIntrinsics% %ConcurrentBuild% %StructMemberAlignment%
 
set DebugCompilerFlags=%DefaultCompilerFlags% %DisableOptimizations% %MultithreadExecDebug% %WarningLevelStrict% %GenerateVersion7Debugging% %DynamicLinkLibrary%
set ReleaseCompilerFlags=%DefaultCompilerFlags% %WarningLevelRelaxed% %FastCode% %DynamicLinkLibrary%

set DefaultLinkerFlags=-opt:ref User32.lib gdi32.lib winmm.lib kernel32.lib

IF NOT EXIST %DefaultBuildDirectory% mkdir %DefaultBuildDirectory%
pushd %DefaultBuildDirectory%

del *.obj /Q

cl %DebugCompilerFlags% %DefaultSourceDirectory%vg_fetch.c /I %DefaultIncludeDirectory% /link %DefaultLinkerflags% /libpath:%DefaultLibDirectory%
lib vg_fetch.obj

pause