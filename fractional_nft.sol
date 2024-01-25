// // SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is IERC20 {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string public _name;
    string public _symbol;

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    constructor(
        string memory name1,
        string memory symbol1,
        address wallet,
        uint256 _supply,
        address wallets,
        address spender,
        uint256 amount,
        address wallet1,
        address spender1
    ) {
        _name = name1;
        _symbol = symbol1;
        _mint(wallet, _supply);
        _approve(wallets, spender, amount);
        allowance(wallet1, spender1);
        // transfer(msg.sender,_supply);
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function _mint(address account, uint256 amount) public {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: from the zero address");
        require(spender != address(0), "ERC20: to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    // 0x9cE26C4dCf389F687F4666B806838AEAA73Acdb4
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }
}





contract Fractional  {
    using SafeMath for uint256;


    ERC1155 EeRC1155 = ERC1155(0x2953399124F0cBB46d2CbACD8A89cF0599974963);


    using Counters for Counters.Counter;

    enum ListingStatus {
        Active,
        Sold,
        Cancelled
    }
    struct saleItem {
        uint256 worth;
        address user;
        uint256 price;
        uint256 commission;
        uint256 seed;
        address ctAddress;
        address tokenads;
    }
    struct purchays {
        address tkn_adrs;
        address ctAddress;
        address user;
        uint256 _howmany;
        uint256 price;
        uint256 total;
        uint256 time;
        bool purchased;
    }

    struct Bid {
        uint256 tokenId;
        address bidder;
        uint256 amount;
        uint256 hwtkn;
    }
    struct forSale {
        ListingStatus status;
        address ctAddress;
        uint256 orderid;
        uint256 tokenid;
        address seller;
        address tkn_adrs;
        uint256 hw_tkn;
        bool isAuction;
        uint256 price;
        uint256 total;
    }
    struct history {
        address tk_drs;
        address tknowner;
        uint256 amount;
    }
    struct Secondhistory {
        address newOwner;
        uint256 amount;
        uint256 worth;
        uint256 commission;
    }
    struct Member {
        uint256 id;
        address user;
        uint256 balce;
    }
    struct TokenAddress {
        address tkn_adrs;
        address ctAddress;
        address user;
        uint256 tokenId;
        string _name;
        string _symbol;
        uint256 _supply;
        uint256 seed;
    }
    address public ownerO;

    constructor() {
        ownerO = msg.sender;
    }

    IERC20 public _token = ERC20(0xb37C9434b0f051193278D869686dF74e8733c035);

    function _setuSDC(address newuSDC) public onlyOwner {
        _token = ERC20(newuSDC);
    }

    modifier onlyOwner() {
        require(msg.sender == ownerO, "Not owner");
        _;
    }

// 0xff28322e1fD7B3dFc5b6A7588acbA947cFB98116
// 0x2d520dd000290db4aE9Ae1eD4c8c391Ca62eaFE9
// 0x3d99fD6Df0222D77829C4B40ae7282248b8c3892

    TokenAddress[] public tkns;
    mapping(address => TokenAddress) public ToknDetail;

    mapping(uint256 => Member[]) public members;

    mapping(address => mapping(address => purchays)) public purchases;
    mapping(address => address[]) public addresses;

    mapping(address => mapping(address => mapping(uint256 => uint256)))
        public   FractionalNFTHoldings;
    mapping(address => mapping(address => mapping(address => uint256)))
        public    SecondaryFractionalNFTHoldings;
    mapping(address => mapping(uint256 => saleItem)) public itemForSale;
    mapping(address => mapping(uint256 => address)) toknADs;

    mapping(uint256 => Bid[]) public BidlistArray;
    mapping(uint256 => mapping(address => mapping(uint256 => uint256)))
        public makeoffers;

    mapping(uint256 => forSale) public forSales;

    mapping(uint256 => uint256) public UpDated_tkBal;
    mapping(address => history[]) public historyofuser;
    mapping(address => Secondhistory[]) public SecondaryMemoryuser;
    mapping(address => uint256) public seedCollection;
    mapping(address => bool) public adrsExists;

    uint256 public tokenCount;
    mapping(address=>bool) peopleWhoentered;

    event fractionalize(
        address tkn_adrs,
        uint256 seed,
        uint256 fractionalization
    );
    event TokenDeployed(address tokenAddress);
    event commision(uint256 commission);
    event purchased(
        address user,
        uint256 total,
        uint256 price,
        address ctaddress,
        uint256 tokenid,
        uint256 bal
    );
    event markket(
        address ctAddress,
        uint256 orderid,
        address tkn_adrs,
        uint256 hw_tkn,
        uint256 _price,
        bool isAuction
    );
    event balance(uint256 balance);
    event buyone(address buyer, uint256 total, uint256 comm_cal);
    event acceptOffer(address bidder, uint256 amount, uint256 comm_cal);
    event distCommission(uint256[] id, address[] user, uint256[] commission);
    event makeOfer(uint256 hwtkn, uint256 amount, address tkn_adrs);
    event tranferself(
        address to,
        uint256 amount,
        address tkn_adrs,
        address ctAddresss,
        uint256 orderid,
        uint256 comm_cal
    );

    mapping(address => mapping(address => uint256)) allowed;
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    mapping(address => bool) internal frozen;
    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused, "whenNotPaused");
        _;
    }

     

    function fractionlize(
        uint256 seedid,
        uint256 commission,
        address ctAddress,
        uint256 tokenId,
        uint256 _price,
        uint256 _supply
    ) public {
        require(
            IERC1155(ctAddress).balanceOf(msg.sender, tokenId) >= 1,
            "No tokens owned!"
        );

        string memory _name = ERC1155(ctAddress).name();
        string memory _symbol = ERC1155(ctAddress).symbol();

        // address owner = msg.sender;
        FractionalNFTHoldings[msg.sender][ctAddress][
            seedid
        ] = FractionalNFTHoldings[msg.sender][ctAddress][seedid].add(_supply);

        uint256 number = uint256(
            keccak256(
                abi.encodePacked(block.timestamp,block.coinbase, msg.sender)
            )
        ) % 10000000;
        string memory newname = string.concat(_name, Strings.toString(number));
        string memory newsymbol = string.concat(
            _symbol,
            Strings.toString(number)
        );
        Token token = new Token(
            newname,
            newsymbol,
            msg.sender,
            _supply,
            msg.sender,
            address(this),
            _supply,
            msg.sender,
            address(this)
        );

        address tkn_adrs = address(token);

        toknADs[ctAddress][seedid] = tkn_adrs;
        seedCollection[tkn_adrs] = seedid;

        ToknDetail[tkn_adrs] = TokenAddress(
            tkn_adrs,
            ctAddress,
            msg.sender,
            tokenId,
            newname,
            newsymbol,
            _supply,
            seedid
        );
        tokenCount += 1;
        tkns.push(ToknDetail[tkn_adrs]);
        itemForSale[tkn_adrs][seedid].worth = _supply;
        itemForSale[tkn_adrs][seedid].user = msg.sender;
        itemForSale[tkn_adrs][seedid].price = _price;
        itemForSale[tkn_adrs][seedid].commission = commission;
        itemForSale[tkn_adrs][seedid].seed = seedid;
        itemForSale[tkn_adrs][seedid].ctAddress = ctAddress;
        itemForSale[tkn_adrs][seedid].tokenads = tkn_adrs;
        emit fractionalize(tkn_adrs, seedid, _supply);
    }

  
  
    function primary(
        uint256 seedid,
        address tkn_adrs,
        uint256 _howmany,
        address nftOwner
    ) external payable {
        require(
            msg.sender != itemForSale[tkn_adrs][seedid].user,
            "owner cannot call this function"
        );

        address ctAddress = ToknDetail[tkn_adrs].ctAddress;
        uint256 tokenId = ToknDetail[tkn_adrs].tokenId;
        // = payable(itemForSale[tkn_adrs].user);
        address owner = msg.sender;

        uint256 price = itemForSale[tkn_adrs][seedid].price;
        uint256 total = _howmany.mul(price);

        // _token.approve(address(this), total);
        _token.transferFrom(owner, nftOwner, total); //usdc

        ERC20(tkn_adrs).transferFrom(nftOwner, owner, _howmany); //erc20

        purchases[tkn_adrs][owner].tkn_adrs = tkn_adrs;
        purchases[tkn_adrs][owner].ctAddress = ctAddress;
        purchases[tkn_adrs][owner].user = owner;
        purchases[tkn_adrs][owner].price = price;
        purchases[tkn_adrs][owner].total = total;
        purchases[tkn_adrs][owner].time = block.timestamp;
        purchases[tkn_adrs][owner].purchased = true;
        //  0x902eDf8C2746b2Bb38E60037541E653106914A89
        history memory historyMemory = history({
            tk_drs: tkn_adrs,
            tknowner: msg.sender,
            amount: total
        });

        historyofuser[tkn_adrs].push(historyMemory);
        adrsExists[owner] = true;
        addresses[tkn_adrs].push(msg.sender);

        uint256 balanvce = ERC20(tkn_adrs).balanceOf(msg.sender);

        if (peopleWhoentered[owner] == false) {
            members[seedid].push(Member(seedid, owner, balanvce));
            peopleWhoentered[owner] = true;

        }
     
        uint256 bala_buyer = _token.balanceOf(owner);
        emit purchased(
            msg.sender,
            total,
            price,
            ctAddress,
            tokenId,
            bala_buyer
        );
    }

    function market(
        uint256 orderid,
        address seller,
        address tkn_adrs,
        uint256 hw_tkn,
        uint256 _price,
        bool isAuction
    ) external {
        address ctAddress = ToknDetail[tkn_adrs].ctAddress;
        uint256 tokenId = ToknDetail[tkn_adrs].tokenId;
        require(purchases[tkn_adrs][seller].purchased, "only  primary buyer");

        require(
            _price <= ERC20(tkn_adrs).balanceOf(msg.sender),
            " you dont have enugh tokens"
        );

        uint256 total = hw_tkn.mul(_price);

        UpDated_tkBal[orderid] = hw_tkn;

        // SecondaryFractionalNFTHoldings[seller][ctAddress][
        //     tkn_adrs
        // ] = SecondaryFractionalNFTHoldings[seller][ctAddress][tkn_adrs].add(
        //     hw_tkn
        // );

        forSales[orderid] = forSale(
            ListingStatus.Active,
            ctAddress,
            orderid,
            tokenId,
            seller,
            tkn_adrs,
            hw_tkn,
            isAuction,
            _price,
            total
        );

        emit markket(ctAddress, orderid, tkn_adrs, hw_tkn, _price, isAuction);
    }

    function buynft(
        uint256 orderid,
        uint256 hwtkn,
        address tkn_adrs,
        address seller
    ) external {
        uint256 tokenId = ToknDetail[tkn_adrs].tokenId;
 
        
        require(forSales[tokenId].status == ListingStatus.Active, "started ");
        uint256 price = forSales[orderid].price;

        uint256 total = price.mul(hwtkn);
                address owner = msg.sender;

        require(
            total <= _token.balanceOf(owner),
            " you dont have enugh tokens"
        );
        // _token.approve(address(this), total);

        uint256 updatedbalceoftoken = UpDated_tkBal[orderid] - hwtkn;
        UpDated_tkBal[orderid] = updatedbalceoftoken;

        uint256 seedid = seedCollection[tkn_adrs];

        // require(purchases[tkn_adrs][seller].purchased, "u can call this");

        forSale storage listedItem = forSales[orderid];
        listedItem.status = ListingStatus.Sold; //setting the status of the nft to sold

        ERC20(tkn_adrs).transferFrom(seller, owner, hwtkn);
        // uSDC
        // address ab =msg.sender;
        Secondhistory memory SecondaryMemory = Secondhistory({
            newOwner: owner,
            amount: total,
            worth: hwtkn,
            commission: 0
        });
        uint256 bal_owner = _token.balanceOf(seller);
        uint256 bal_buyer = _token.balanceOf(owner);

        // _token.approve(address(this), total);

        _token.transferFrom(msg.sender, seller, total);

        if (bal_buyer > 0 && bal_owner > 0) {
            delete seller;
            delete owner;
        } else if (bal_buyer < 0 && bal_owner < 0) {
            addresses[tkn_adrs].push(owner);
            addresses[tkn_adrs].push(seller);
        }

        SecondaryMemoryuser[tkn_adrs].push(SecondaryMemory);

      uint256 balanvce = ERC20(tkn_adrs).balanceOf(msg.sender);

    if (peopleWhoentered[owner] == false) {
        members[seedid].push(Member(seedid, owner, balanvce));
        peopleWhoentered[owner] = true;
     }
     
        emit buyone(msg.sender, total, 0);
    }

    
//   0xff28322e1fD7B3dFc5b6A7588acbA947cFB98116
// 0x3d99fD6Df0222D77829C4B40ae7282248b8c3892
// 0xA7Ca4DD3FCE1eD98F001a5B17Df9dc41091f4E27
 


    function makeoffer(
        uint256 auctionId,
        uint256 hwtkn,
        uint256 amount,
        address tkn_adrs
    ) external payable {
        // address ctAddresss =ToknDetail[tkn_adrs].ctAddress;
        uint256 tokenId = ToknDetail[tkn_adrs].tokenId;
        //  ToknDetail[tkn_adrs]=TokenAddress(owner,ctAddress,tokenId,_price,_name,_symbol,_supply,seed);
        address bidder = msg.sender;
        require(forSales[auctionId].isAuction == true, "you can make offer");
        require(
            forSales[auctionId].status == ListingStatus.Active,
            " started "
        );
        // require(bidder ==itemForSale[ctAddresss][tokenId][tkn_adrs].user,"only primary buyers");
        require(adrsExists[msg.sender], "address does not exist");
        require(
            amount <= ERC20(tkn_adrs).balanceOf(bidder),
            " you dont have enugh tokens"
        );

        uint256 seed = seedCollection[tkn_adrs];
        // uint256 _supply = itemForSale[tkn_adrs][seed].worth;
        Bid memory bidMemory = Bid({
            tokenId: tokenId,
            bidder: bidder,
            hwtkn: hwtkn,
            amount: amount
        });

        BidlistArray[auctionId].push(bidMemory);

       makeoffers[auctionId][bidder][seed] = amount;
        emit makeOfer(hwtkn, amount, tkn_adrs);
    }
    function acceptoffer(
        uint256 auctionid,
        address bidder,
        uint256 bidamount,
        uint256 hwtkn,
        address tkn_adrs,
        address seller
    ) external payable {
        uint256 hw_tkn = UpDated_tkBal[auctionid];
        uint256 updatedbalceoftoken = hw_tkn - hwtkn;
        UpDated_tkBal[auctionid] = updatedbalceoftoken;

        uint256 seedid = seedCollection[tkn_adrs];


        uint256 balanvce = ERC20(tkn_adrs).balanceOf(bidder);

            if (peopleWhoentered[bidder] == false) {
    
            members[seedid].push(Member(seedid, bidder, balanvce));
            peopleWhoentered[bidder] = true;

        }

        _token.transferFrom(bidder, seller, bidamount); //usdc

        ERC20(tkn_adrs).transferFrom(bidder, seller, bidamount);

        emit acceptOffer(bidder, bidamount, 0);
    }

   

    function distribute(uint256 _seedid,address tkn_adrs,uint256 commission)
    public returns(Member[] memory) {
    uint256[] memory id = new uint256[](members[_seedid].length);
    address[] memory user = new address[](members[_seedid].length);
    uint256[] memory balce = new uint256[](members[_seedid].length);
    uint256[] memory balanze= new uint256[](members[_seedid].length);
    uint256 len = members[_seedid].length;
    for (uint256 i = 0; i < members[_seedid].length; i++)
    { 
        id[i] = members[_seedid][i].id;
        user[i] = members[_seedid][i].user;
        balce[i] =ERC20(tkn_adrs).balanceOf( user[i]);
        balanze[i]=ERC20(tkn_adrs).balanceOf( user[i]);
                if (balce[i]!=0)
    {        
            ERC20(tkn_adrs).transferFrom(msg.sender,user[i],  commission);
    } 
    
        if (balce[i] == 0) {
        members[_seedid][i].balce = members[_seedid][len-1].balce;
        members[_seedid][i].user =  members[_seedid][len-1].user;
            members[_seedid].pop();
    }
            len = members[_seedid].length;
        if (members[_seedid][0].balce == 0) {
        members[_seedid][0].balce = members[_seedid][len-1].balce;
        members[_seedid][0].user =  members[_seedid][len-1].user;
            members[_seedid].pop();
            }
        }
    return members[_seedid];
    }




    function getTokenBalance(address _contractAddr, uint256 _tokenId)
        public
        view
        returns (uint256)
    {
        ERC1155 token = ERC1155(_contractAddr);
        return token.balanceOf(msg.sender, _tokenId);
    }


    function showmembers(uint256 seedid)
            external
            view
            returns (Member[] memory)
        {
            return members[seedid];
        }


    function showBalance(uint256 _seedid, address tkn_adrs) public view  returns (uint256[] memory,address[] memory,uint256[] memory){
        uint256[] memory id = new uint256[](members[_seedid].length);
        address[] memory user = new address[](members[_seedid].length);
        uint256[] memory balce = new uint256[](members[_seedid].length);

        for (uint256 i = 0; i < members[_seedid].length; i++) {
            id[i] = members[_seedid][i].id;
            user[i] = members[_seedid][i].user;
            balce[i]=ERC20(tkn_adrs).balanceOf( user[i]);
        }
        return (id, user, balce);
    }

   function TokenBalanZe(
        address _contractAddr,
        address owner,
        uint256 _tokenId
    ) public view returns (uint256) {
        ERC1155 token = ERC1155(_contractAddr);
        return token.balanceOf(owner, _tokenId);
    }
    
        function getTokenAddresssDetails()
        public
        view
        returns (TokenAddress[] memory)
    {
        return tkns;
    }

    function showoffers(uint256 auctionid)
        external
        view
        returns (Bid[] memory)
    {
        return BidlistArray[auctionid];
    }

    function balanceofuser(address user, address tkn_adrs) public {
        emit balance(ERC20(tkn_adrs).balanceOf(user));
    }

    function showbuyer(address tkn_adrs)
        external
        view
        returns (history[] memory)
    {
        return historyofuser[tkn_adrs];
    }

  

    function getContractBalance(address ContractAddress)
        public
        view
        returns (uint256)
    {
        return ContractAddress.balance;
    }

    function getTotalSupply(address addr) public view returns (uint256) {
        return ERC20(addr).totalSupply();
    }
    

   
}

