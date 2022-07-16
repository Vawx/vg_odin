@echo off

IF NOT DEFINED clset (call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" x64)

:: docs.microsoft.com/en-us/cpp/build/reference/compiler-options-listed-by-category?view=vs-2019

set MultithreadCompile=-MT
set NoLogo=-nologo
set RuntimeInformation=-GR-
set ModernCatchExceptions=-EHa-
set NoExternCExceptions=-EHsc
set DisableOptimization=-Od
set GenerateIntrinsics=-Oi
set WarningLevel=-W2
set WarningAsErrors=-WX
set DisplayFullSourcePath=-FC
set GenerateVersion7Debugging=-Z7

set IgnoreConversionOfGreaterSize=-wd4312
set IgnoreTrunctionOfPointerType=-wd4311 -wd4302

set IncludeRegistryLib=Advapi32.lib

set CommonCompilerFlags=%MultithreadCompile% %NoLogo% %RuntimeInformation% %ModernCatchExceptions% %NoExternCExceptions% %DisableOptimization% %GenerateIntrinsics% %WarningLevel% %WarningsAsErrors% %DisplayFullSourcePaths% %GenerateVersion7Debugging% %IgnoreConversionOfGreaterSize% %IgnoreTrunctionOfPointerType% %UsingEditor% %AssertOnCriticalLog% %TestGL%

set CommonLinkerFlags=-opt:ref User32.lib gdi32.lib winmm.lib opengl32.lib Comdlg32.lib %IncludeRegistryLib%
set GlewLinkerFlags=glew32.lib glew32s.lib
set ImguiCompile=..\include\imgui\imgui*.cpp ..\include\imgui\backends\imgui_impl_win32.cpp ..\include\imgui\backends\imgui_impl_opengl3.cpp

IF NOT EXIST build  mkdir build
pushd build

del *.obj /Q

REM 64 bit build
cl %CommonCompilerFlags% ..\viewer.c ..\external.c ..\..\..\ufbx.c /link %CommonLinkerFlags%
