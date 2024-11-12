dynamic_array: public(DynArray[uint256, 100]) # length will start at 0
# and everytime you add something to the array/list it'll grow in size
fixed_sized_array: public(uint256[100]) # "length of this array = 100"
 # [0, 0, 0, 0, 0.... 0]
index: uint256

@external 
@view 
def dyn_array_size() -> uint256:
    return len(self.dynamic_array)

@external
def add_to_array():
    self.fixed_sized_array[self.index] = 1
    self.dynamic_array.append(1)
    self.index = self.index + 1