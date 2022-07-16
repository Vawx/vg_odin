@echo off

IF NOT DEFINED clset (call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" x64)

odin build D:/vgo/source/ -debug
