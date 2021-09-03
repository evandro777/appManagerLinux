#.NET Core

#stable
sudo snap install dotnet-sdk --classic

#Beta
#sudo snap install dotnet-sdk --beta --classic

#When .NET Core in installed using the Snap package, the default .NET Core command is dotnet-sdk.dotnet, as opposed to just dotnet.
#The benefit of the namespaced command is that it will not conflict with a globally installed .NET Core version you may have.
#This command can be aliased to dotnet with:

sudo snap alias dotnet-sdk.dotnet dotnet