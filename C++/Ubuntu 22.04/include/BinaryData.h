//
//  BinaryData.h
//  BayunCppXproj
//
//  Created by Preeti Gaur on 09/04/20.
//  Copyright © 2020 Bayun Systems Inc. All rights reserved.
//

#ifndef BinaryData_h
#define BinaryData_h

#include <memory>
#include <stdio.h>
#include <string>

namespace Bayun {

/**
 * \class BinaryData
 */
class BinaryData {
  
  public :
  
  unsigned char* data_;
  size_t dataLen_;
  
  /**
   * BinaryData Constructor
   */
  BinaryData(std::string cipher) {
    size_t len = cipher.length();
    data_ = (unsigned char*)malloc(len);
    memcpy(data_, cipher.c_str(), len);
    dataLen_ = len;
  }
  
  /**
   * BinaryData Destructor
   */
  ~BinaryData() {
    free(data_);
  };
};

using ShLockedData = std::shared_ptr<BinaryData>;
using ShUnlockedData = std::shared_ptr<BinaryData>;

}  // namespace Bayun
#endif /* BinaryData_h */
