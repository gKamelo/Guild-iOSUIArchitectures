# iOS UI Architectures

![Xcode version](https://img.shields.io/badge/Xcode-9.2-blue.svg)
![Swift version](https://img.shields.io/badge/Swift-4.0-blue.svg)
![Swiftlint version](https://img.shields.io/badge/Swiftlint-0.23.0-blue.svg)

Part of brown bag/guild meeting to present some of the most commonly used iOS UI architectures.

## General

There are two main elements in repository.

* Xcode project for architectures
* Vapor service to imitate network service.

### Project overview

Project contains 3 architectures.

* [MVC](https://developer.apple.com/library/content/documentation/General/Conceptual/DevPedia-CocoaCore/MVC.html) - Apple way, where controller is a glue code for model and view interactions.
* [MVVM](https://en.wikipedia.org/wiki/Model–view–viewmodel) - Extension of Apple MVC with one more abstraction layer for presentation logic (ViewModel) and custom communication between model and view changes.
* [C-MVVM](http://khanlou.com/2015/10/coordinators-redux/) - Extension of MVVM with additional layer for navigation within application (Coordinators).

All architectures share part of code (networking, models, modals) to better present differences between them, under `FIXME` Xcode mark there could be found hints/problems of each of them.

C-MVVM has some sample tests to present simple way to mock network requests in Swift code.

### Execution

In order to launch application, please follow below steps.

#### Vapor service

* Install [Vapor toolbox](https://docs.vapor.codes/2.0/getting-started/toolbox/)
* Open Terminal in root folder and execute
```bash
$ cd TasksService
$ vapor build
$ vapor run
```

#### Architecture project

Open architecture Xcode project and run one of the targets

* MVC
* MVVM
* C-MVVM

## License

Code is released under the MIT license. See [LICENSE](LICENSE) for details.
