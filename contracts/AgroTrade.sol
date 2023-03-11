// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FarmerMarketplace {
    struct Product {
        uint id;
        string name;
        uint price;
        uint quantity;
        address farmer;
        bool sold;
    }

    struct ProductBidding {
        uint id; // bidding id
        uint prod_id; // product id
        uint price;
        address owner;
    }

    struct Farmer {
        string name;
        string phone;
        address farmer;
    }

    struct Merchant {
        string name;
        string phone;
        address merchant;
    }

    mapping(uint => Product) public products;
    mapping(uint => ProductBidding) public product_bidding;

    Product[] public products_list;
    ProductBidding[] public product_bidding_list;

    uint public productsCount;
    uint public product_biddingCount;

    event ProductAdded(
        uint id,
        string name,
        uint price,
        uint quantity,
        address farmer
    );
    event ProductSold(uint id, address merchant);

    function addProduct(
        string memory _name,
        uint _price,
        uint _quantity
    ) public {
        productsCount++;
        products[productsCount] = Product(
            productsCount,
            _name,
            _price,
            _quantity,
            msg.sender,
            false
        );
        products_list.push(products[productsCount]);
        emit ProductAdded(productsCount, _name, _price, _quantity, msg.sender);
    }

    // product get bought by merchant directly without bidding
    function buyProduct(uint _id, uint _quantity) public payable {
        Product storage product = products[_id];

        require(product.sold == false, "Product is sold out");
        require(
            product.id > 0 && product.id <= productsCount,
            "Invalid product ID"
        );
        require(product.quantity > 0, "Product is sold out");
        require(product.quantity >= _quantity, "Product is sold out");

        require(
            product.farmer != msg.sender,
            "You cannot buy your own product"
        );

        product.quantity -= _quantity;
        if (product.quantity == 0) {
            product.sold = true;
        }
        emit ProductSold(_id, msg.sender);

        payable(product.farmer).transfer(product.price * _quantity);
    }

    // farmer can set bid for his product
    function setBid(uint _prodid, uint _price) public {
        Product storage product = products[_prodid];

        require(product.sold == false, "Product is sold out");
        require(
            product.id > 0 && product.id <= productsCount,
            "Invalid product ID"
        );
        product_biddingCount++;
        ProductBidding storage bid = product_bidding[product_biddingCount];
        bid.id++;
        bid.owner = msg.sender;
        bid.price = _price;
    }

    //  merchant accepts bid  _id : bid id

    function AcceptBid(uint _id, uint _quantity) public {
        ProductBidding storage bid = product_bidding[_id];

        Product storage product = products[bid.prod_id];

        require(product.sold == false, "Product is sold out");
        require(
            product.id > 0 && product.id <= productsCount,
            "Invalid product ID"
        );
        require(product.quantity > 0, "Product is sold out");
        require(product.quantity >= _quantity, "Product is sold out");

        payable(product.farmer).transfer(product.price * _quantity);
    }

    function editBid(uint _id, uint _price) public {
        ProductBidding storage bid = product_bidding[_id];

        require(bid.id > 0 && bid.id <= product_biddingCount, "Invalid bid ID");
        require(bid.owner == msg.sender, "You are not the owner of this bid");

        bid.price = _price;
    }

    function deleteBid(uint _id) public {
        ProductBidding storage bid = product_bidding[_id];

        require(bid.id > 0 && bid.id <= product_biddingCount, "Invalid bid ID");
        require(bid.owner == msg.sender, "You are not the owner of this bid");

        delete product_bidding[_id];
    }

    function getProducts() public view returns (Product[] memory) {
        return products_list;
    }

    function getBids() public view returns (ProductBidding[] memory) {
        return product_bidding_list;
    }

    function getProductsByFarmer(
        address _farmer
    ) public view returns (Product[] memory) {
        Product[] memory result = new Product[](productsCount);
        uint counter = 0;
        for (uint i = 1; i <= productsCount; i++) {
            if (products[i].farmer == _farmer) {
                result[counter] = products[i];
                counter++;
            }
        }
        Product[] memory result2 = new Product[](counter);
        for (uint i = 0; i < counter; i++) {
            result2[i] = result[i];
        }
        return result2;
    }

    function getBidsByFarmer(
        address _farmer
    ) public view returns (ProductBidding[] memory) {
        ProductBidding[] memory result = new ProductBidding[](
            product_biddingCount
        );
        uint counter = 0;
        for (uint i = 1; i <= product_biddingCount; i++) {
            if (product_bidding[i].owner == _farmer) {
                result[counter] = product_bidding[i];
                counter++;
            }
        }
        ProductBidding[] memory result2 = new ProductBidding[](counter);
        for (uint i = 0; i < counter; i++) {
            result2[i] = result[i];
        }
        return result2;
    }

    function getBidsByProduct(
        uint _prodid
    ) public view returns (ProductBidding[] memory) {
        ProductBidding[] memory result = new ProductBidding[](
            product_biddingCount
        );
        uint counter = 0;
        for (uint i = 1; i <= product_biddingCount; i++) {
            if (product_bidding[i].prod_id == _prodid) {
                result[counter] = product_bidding[i];
                counter++;
            }
        }
        ProductBidding[] memory result2 = new ProductBidding[](counter);
        for (uint i = 0; i < counter; i++) {
            result2[i] = result[i];
        }
        return result2;
    }
}
