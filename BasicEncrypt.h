//
//  BasicEncrypt.h
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 7/6/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#ifndef __SmartWorkspace__BasicEncrypt__
#define __SmartWorkspace__BasicEncrypt__

#include <stdio.h>
#include <string>

using namespace std;

class BasicEncHelper {
private:
    static string key;
public:
    static string encrypt(string message);
};
#endif /* defined(__SmartWorkspace__BasicEncrypt__) */
