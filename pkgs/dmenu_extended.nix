{ lib, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "dmenu_extended";
  version = "1.2.1";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "80ef8762cf48fa7683e1904b4e70135b29b86fb2b4c966c5a38ccebef818a633";
  };

  # PEP 517/518 builds typically require `format = "pyproject"`;
  format = "pyproject";

  nativeBuildInputs = [ python3Packages.setuptools ];

  # Specify dependencies here
  propagatedBuildInputs = [ python3Packages.setuptools ];

  meta = with lib; {
    description = "A description of the dmenu_extended package";
    homepage = "https://example.com";
    license = licenses.mit; # Adjust the license accordingly
  };
}
