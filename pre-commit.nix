{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, wheel
}:

buildPythonPackage rec {
  pname = "pre_commit";
  version = "3.7.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-4gnWG4rNz3QkBECFMfDDfUnSxzT9fP8tYHYIPRkcsGA=";
  };

  # do not run tests
  doCheck = false;

  propagatedBuildInputs = [
    # ...
    setuptools
  ];

  # specific to buildPythonPackage, see its reference
  pyproject = true;
  build-system = [
    setuptools
    wheel
  ];
}
