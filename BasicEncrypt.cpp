//
//  BasicEncrypt.cpp
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 7/6/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#include "BasicEncrypt.h"

string BasicEncHelper::key = "%#&";

string BasicEncHelper::encrypt(string message) {
    string output = message;
    int keyIndex = 0;
    for (int i = 0; i < message.size(); i++) {
        output[i] = message[i] ^ key[keyIndex];
        keyIndex++;
        if (keyIndex == key.size()) {
            keyIndex = 0;
        }
    }
    return output;
}