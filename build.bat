SET TYPE=%CONFIGURATION%
SET DEVSPACE=%APPVEYOR_BUILD_FOLDER%\..
cd %DEVSPACE%
Invoke-WebRequest http://draconpern-buildcache.s3.amazonaws.com/dcmtk-win.7z -Outfile "dcmtk-win.7z"
7z x -y dcmtk-win.7z
cd %DEVSPACE%
git clone --branch=master https://github.com/uclouvain/openjpeg.git
cd openjpeg && git checkout openjpeg-2.1 && mkdir build-%TYPE% && cd build-%TYPE%
cmake .. -G "Visual Studio 11" -DBUILD_THIRDPARTY=ON -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS_RELEASE="/MT /O2 /D NDEBUG" -DCMAKE_C_FLAGS_DEBUG="/D_DEBUG /MTd /Od" -DCMAKE_INSTALL_PREFIX=%DEVSPACE%\openjpeg\%TYPE%
msbuild /P:Configuration=%TYPE% INSTALL.vcxproj

cd %APPVEYOR_BUILD_FOLDER% && mkdir build-%TYPE% && cd build-%TYPE%
cmake .. -G "Visual Studio 11" -DBUILD_SHARED_LIBS=OFF -DCMAKE_CXX_FLAGS_RELEASE="/MT /O2 /D NDEBUG" -DCMAKE_CXX_FLAGS_DEBUG="/D_DEBUG /MTd /Od" -DOPENJPEG=%DEVSPACE%\openjpeg\%TYPE% -DDCMTK_DIR=%DEVSPACE%\dcmtk\%TYPE% -DCMAKE_INSTALL_PREFIX=%APPVEYOR_BUILD_FOLDER%\%TYPE%

cd %APPVEYOR_BUILD_FOLDER%\build-%TYPE%
msbuild /P:Configuration=%TYPE% INSTALL.vcxproj

cd %DEVSPACE%
7z a fmjpeg2koj-win.7z fmjpeg2koj\%TYPE% openjpeg\%TYPE%

mv fmjpeg2koj-win.7z %APPVEYOR_BUILD_FOLDER%
