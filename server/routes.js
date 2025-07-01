import fs from "fs";
let db = JSON.parse(fs.readFileSync("./database.json", "utf-8"));

// Function to save database changes
const saveDatabase = () => {
  fs.writeFileSync("./database.json", JSON.stringify(db, null, 2));
};

// Menyimpan ID produk yang ada di wishlist. Set efisien untuk data unik.
const wishlistedProductIds = new Set(Array.isArray(db.wishlistedProductIds) ? db.wishlistedProductIds : [9, 10, 8, 5]);

// Menyimpan item di keranjang belanja. Map ideal untuk `productId` => `quantity`.
const shoppingCart = new Map(
  Array.isArray(db.shoppingCart)
    ? db.shoppingCart.map(([k, v]) => [Number(k), v])
    : []
);

// --- Helper Functions ---
/**
 * Menambahkan flag `isWishlisted` ke setiap objek produk.
 * @param {object} product - Objek produk asli.
 * @returns {object} Produk dengan flag isWishlisted.
 */
const addWishlistStatus = (product) => 
{
  return {
    ...product,
    isWishlisted: wishlistedProductIds.has(product.id),
  };
};

const routes = [
  // --- Informasi Endpoint ---
  {
    method: "GET",
    path: "/",
    handler: (request, h) => 
    {
      return {
        message: "Selamat datang di Product API!",
        version: "1.0.0",
        endpoints: 
        {
          all_products: "/products",
          new_products: "/products/new",
          popular_products: "/products/popular",
          carousel_products: "/products/carousel",
          product_by_id: "/products/{id}",
          add_product: "POST /products",

          wishlist: "/products/wishlist",
          add_to_wishlist: "POST /products/{id}/wishlist",
          remove_from_wishlist: "DELETE /products/{id}/wishlist",

          shopping_cart: "/cart",
          add_to_cart: "POST /cart",
          remove_from_cart: "DELETE /cart/item/{id}",
        },
      };
    },
  },

  // --- Endpoint Produk ---
  {
    method: "GET",
    path: "/products",
    handler: (request, h) => 
    {
      const productsWithStatus = db.products.map(addWishlistStatus);
      return h.response(productsWithStatus);
    },
  },
  {
    method: "GET",
    path: "/products/new",
    handler: (request, h) => 
    {
      const newProducts = db.products
        .filter((product) => db.newProductIds.includes(product.id))
        .map(addWishlistStatus);

      return h.response(newProducts);
    },
  },
  {
    method: "GET",
    path: "/products/popular",
    handler: (request, h) => 
    {
      const popularProducts = db.products
        .filter((product) => db.popularProductIds.includes(product.id))
        .map(addWishlistStatus);

      return h.response(popularProducts);
    },
  },
  {
    method: "GET",
    path: "/products/{id}",
    handler: (request, h) => 
    {
      const id = parseInt(request.params.id, 10);
      const product = db.products.find((p) => p.id === id);

      if (product) 
      { return h.response(addWishlistStatus(product)); }

      return h
        .response({ message: "Product not found" })
        .code(404);
    },
  },
  {
    method: "GET",
    path: "/products/carousel",
    handler: (request, h) => 
    {
      // Ambil 5 produk acak dari seluruh produk
      const shuffled = [...db.products].sort(() => 0.5 - Math.random());
      const carouselProducts = shuffled.slice(0, 5).map(addWishlistStatus);
      return h.response(carouselProducts);
    },
  },

  // --- Endpoint Wishlist ---
  {
    method: "GET",
    path: "/products/wishlist",
    handler: (request, h) => 
    {
      const wishlistedProducts = db.products
        .filter((product) => wishlistedProductIds.has(product.id))
        .map(p => ({ ...p, isWishlisted: true }));

      return h.response(wishlistedProducts);
    },
  },
  {
    method: "POST",
    path: "/products/{id}/wishlist",
    handler: (request, h) => {
      const id = parseInt(request.params.id, 10);
      const product = db.products.find((p) => p.id === id);

      if (!product) {
        return h.response({ message: "Product not found" }).code(404);
      }

      wishlistedProductIds.add(id);
      
      // Save wishlist to database
      db.wishlistedProductIds = Array.from(wishlistedProductIds);
      saveDatabase();

      return h.response({
        message: "Product added to wishlist",
        product: addWishlistStatus(product),
      });
    },
  },
  {
    method: "DELETE",
    path: "/products/{id}/wishlist",
    handler: (request, h) => {
      const id = parseInt(request.params.id, 10);
      const product = db.products.find((p) => p.id === id);

      if (!product) {
        return h.response({ message: "Product not found" }).code(404);
      }

      wishlistedProductIds.delete(id);
      
      // Save wishlist to database
      db.wishlistedProductIds = Array.from(wishlistedProductIds);
      saveDatabase();

      return h.response({
        message: "Product removed from wishlist",
        product: addWishlistStatus(product),
      });
    },
  },

  // --- Endpoint Keranjang Belanja (Cart) ---
  {
    method: "GET",
    path: "/cart",
    handler: (request, h) => 
    {
      const itemsInCart = [];
      let totalPrice = 0;
      let totalItems = 0;

      for (const [productId, quantity] of shoppingCart.entries()) 
      {
        const product = db.products.find((p) => p.id === productId);
        if (product) 
        {
          itemsInCart.push({ ...product, quantityInCart: quantity });
          totalPrice += (product.priceIdr || 0) * quantity;
          totalItems += quantity;
        }
      }

      return h.response({
        items: itemsInCart,
        summary: {
          totalPrice: totalPrice,
          totalItems: totalItems,
        }
      });
    },
  },
  {
    method: "POST",
    path: "/cart",
    handler: (request, h) => {
      const { productId, quantity = 1 } = request.payload;
      const pid = Number(productId);
      const qty = Number(quantity);
      const product = db.products.find((p) => p.id === pid);
      if (!product) {
        return h.response({ message: "Product not found" }).code(404);
      }
      if (qty < 1) {
        return h.response({ message: "Quantity must be at least 1." }).code(400);
      }
      if (qty > product.stock) {
        return h.response({ message: `Insufficient stock for ${product.name}. Only ${product.stock} available.` }).code(400);
      }
      shoppingCart.set(pid, qty);
      db.shoppingCart = Array.from(shoppingCart.entries());
      saveDatabase();
      return h.response({
        message: "Cart updated successfully",
        productId: pid,
        quantity: qty,
      });
    },
  },
  {
    method: "POST",
    path: "/cart/item",
    handler: (request, h) => 
    {
      const { productId } = request.payload;
      if (!productId) {
        return h.response({ message: "Invalid input. 'productId' is required." }).code(400);
      }
      const pid = Number(productId);
      const product = db.products.find((p) => p.id === pid);
      if (!product) {
        return h.response({ message: "Product not found" }).code(404);
      }
      const currentQty = shoppingCart.get(pid) || 0;
      if (currentQty + 1 > product.stock) {
        return h.response({ message: `Insufficient stock for ${product.name}. Only ${product.stock - currentQty} left in cart.` }).code(400);
      }
      shoppingCart.set(pid, currentQty + 1);
      db.shoppingCart = Array.from(shoppingCart.entries());
      saveDatabase();
      return h.response({
        message: `${product.name} has been added to your cart (total: ${currentQty + 1}).`,
        cart: Object.fromEntries(shoppingCart)
      }).code(200);
    },
  },
  {
    method: "DELETE",
    path: "/cart/item/{id}",
    handler: (request, h) => {
      const id = parseInt(request.params.id, 10);
      if (!shoppingCart.has(id)) {
        return h.response({ message: "Product not in cart" }).code(404);
      }
      shoppingCart.delete(id);
      db.shoppingCart = Array.from(shoppingCart.entries());
      saveDatabase();
      return h.response({
        message: "Product removed from cart",
        productId: id,
      });
    },
  },
  {
    method: "POST",
    path: "/products",
    handler: (request, h) => {
      const newProduct = request.payload;
      
      // Validate required fields
      if (!newProduct.name || !newProduct.priceIdr || !newProduct.imageUrl || !newProduct.tags || !newProduct.stock) {
        return h.response({
          status: "error",
          message: "Missing required fields. Required: name, priceIdr, imageUrl, tags, stock"
        }).code(400);
      }

      // Generate new ID
      const maxId = Math.max(...db.products.map(p => p.id));
      const newId = maxId + 1;

      // Create the product object
      const productToAdd = {
        id: newId,
        name: newProduct.name,
        priceIdr: newProduct.priceIdr,
        imageUrl: newProduct.imageUrl,
        tags: newProduct.tags,
        rating: newProduct.rating || 0,
        stock: newProduct.stock,
        description: newProduct.description || ""
      };

      // Add to database
      db.products.push(productToAdd);
      
      // Save changes to file
      saveDatabase();

      return h.response({
        status: "success",
        message: "Product added successfully",
        product: addWishlistStatus(productToAdd)
      }).code(201);
    }
  },
];

export default routes;