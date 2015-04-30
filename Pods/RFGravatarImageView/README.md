RFGravatarImageView
====================

A simple UIImageView subclass for dealing with http://gravatar.com images.

##Installation

### Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like RFGravatarImageView in your projects.

#### Podfile

```ruby
platform :ios, '7.0'
pod "RFGravatarImageView", "~> 1.1"
```

### Installation without CocoaPods

Just drag the RFGravatarImageView folder into your project and import it.  You'll also have to download SDWebImage, which you can grab here: [SDWebImage repository](https://github.com/rs/SDWebImage).

```obj-c
#import 'RFGravatarImageView.h'
```

## Use

RFGravatarImageView is pretty easy to use.  See this example implementation (copy/paste from demo project).

```obj-c
_imageView = [[RFGravatarImageView alloc] initWithFrame:self.view.bounds];
_imageView.email = @"test@test.com";
_imageView.forceDefault = YES;
_imageView.defaultGravatar = RFDefaultGravatarMysteryMan;
_imageView.size = 1024;

[self.view addSubview:_imageView];

[_imageView load];
```

See [RFGravatarImageView.h](RFGravatarImageView/RFGravatarImageView.h) to view each available method and the variables - I've commented on everything you need (I think).  For more information on the Gravatar image requests, see [here](https://en.gravatar.com/site/implement/images).

Hope you enjoy it!  Please Fork and send Pull Requests!

##Screenshots

![RFGravatarImageView](http://i.imgur.com/yCvcY4M.pngg)

##License

The MIT License (MIT)

Copyright (c) 2015 Rudd Fawcett

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
