"""
@ pragma version 0.4.0
@ pragma enable-decimals
@ license: MIT
@ title A sample buy-me-a-coffee contract
@ author You!
@ notice This contract is for creating a sample funding contract
"""
# We'll learn a new way to do interfaces later...
interface AggregatorV3Interface:
    def decimals() -> uint8: view
    def description() -> String[1000]: view
    def version() -> uint256: view
    def latestAnswer() -> int256: view

# minimum_usd_decimals: public(constant(decimal)) = 50.0 
MINIMUM_USD: public(constant(uint256)) = 50 * (10**18)
PRECISION: constant(uint256) = 1 * (10**18)
OWNER: public(immutable(address))

funders: public(DynArray[address, 100])
address_to_amount_funded: public(HashMap[address, uint256])
price_feed: public(AggregatorV3Interface)

@deploy
def __init__(price_feed: address):
    self.price_feed = AggregatorV3Interface(price_feed)
    OWNER = msg.sender


@internal
def _only_owner():
    assert msg.sender == OWNER, "Not the contract owner"


@external
@payable
def fund():
    # as_wei_value
    usd_value_of_eth: uint256 = self._get_eth_to_usd_rate(self.price_feed, msg.value)
    assert usd_value_of_eth >= MINIMUM_USD, "You need to spend more ETH!"
    self.address_to_amount_funded[msg.sender] += msg.value
    self.funders.append(msg.sender)


@external
def withdraw():
    self._only_owner()
    for funder: address in self.funders:
        self.address_to_amount_funded[funder] = 0
    self.funders = []
    send(OWNER, self.balance)

@internal
@view
def _get_eth_to_usd_rate(price_feed: AggregatorV3Interface, eth_amount: uint256) -> uint256:
    # Check the conversion rate
    price: int256 = staticcall price_feed.latestAnswer()
    eth_price: uint256 = (convert(price, uint256)) * (10**10)
    eth_amount_in_usd: uint256 = (eth_price * eth_amount) // PRECISION
    return eth_amount_in_usd

@external
@view
def get_version() -> uint256:
    return staticcall self.price_feed.version()

@external
@view
def get_funder(index: uint256) -> address:
    return self.funders[index]

@external
@payable
def __default__():
    pass

# @external 
# @view 
# def get_price() -> int256:
#     price_feed: AggregatorV3Interface = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306)
#     # ABI
#     # Addresss
#     return staticcall price_feed.latestAnswer()

# 4 / 2 = 2
# # 6 / 3 = 2
# # 7 / 3 = 2 (remove all decimals)
# @external 
# @view 
# def divide_me(number: uint256) -> uint256:
#     return number // 3