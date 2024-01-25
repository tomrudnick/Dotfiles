with import <nixpkgs> {};
with pkgs.python3Packages;


buildPythonPackage rec {
  pname = "dmenu_extended";
  version = "1.2.1"; 

  src = fetchPypi {
    inherit pname version;
    sha256 = "80ef8762cf48fa7683e1904b4e70135b29b86fb2b4c966c5a38ccebef818a633"; 
  };

  # Specify dependencies if there are any
  propagatedBuildInputs = [ ];


  meta = with lib; {
    description = "An extension to dmenu for quickly opening files and folders.";
    homepage = "https://github.com/MarkHedleyJones/dmenu-extended"; 
    license = licenses.mit;  # 
    maintainers = with maintainers; [ ]; 
  };
}