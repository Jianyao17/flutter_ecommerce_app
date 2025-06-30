import fs from "fs";
const db = JSON.parse(fs.readFileSync("./database.json", "utf-8"));

// Menyimpan ID produk yang ada di wishlist. Set efisien untuk data unik.
const wishlistedProductIds = new Set([9, 10, 8, 5]); // Inisialisasi dengan beberapa item

// Menyimpan item di keranjang belanja. Map ideal untuk `productId` => `quantity`.
const shoppingCart = new Map();

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
    handler: (request, h) => 
    {
      const id = parseInt(request.params.id, 10);
      const productExists = db.products.some((p) => p.id === id);

      if (!productExists) 
      {
        return h
          .response({ message: "Product not found" })
          .code(404);
      }

      wishlistedProductIds.add(id);
      return h
        .response({
          message: `Product with id ${id} has been added to wishlist.`,
          wishlistedIds: [...wishlistedProductIds],
        }).code(200);
    },
  },
  {
    method: "DELETE",
    path: "/products/{id}/wishlist",
    handler: (request, h) => 
    {
      const id = parseInt(request.params.id, 10);

      if (wishlistedProductIds.has(id)) 
      {
        wishlistedProductIds.delete(id);
        return h
          .response({
            message: `Product with id ${id} has been removed from wishlist.`,
            wishlistedIds: [...wishlistedProductIds],
          }).code(200);
      }

      return h
        .response({ message: "Product was not in wishlist." })
        .code(404);
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
          totalPrice += product.price * quantity;
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
    handler: (request, h) => 
    {
      const { productId, quantity } = request.payload;

      // Validasi input
      if (!productId || !quantity || typeof quantity !== 'number' || quantity <= 0) 
      {
        return h
          .response({ message: "Invalid input. 'productId' and a positive 'quantity' are required." })
          .code(400);
      }

      const product = db.products.find((p) => p.id === productId);
      if (!product) 
      {
        return h
          .response({ message: "Product not found" })
          .code(404);
      }
      if (quantity > product.stock) 
      {
        return h
          .response({ message: `Insufficient stock for ${product.name}. Only ${product.stock} left.` })
          .code(400);
      }

      // Menambahkan atau memperbarui jumlah barang di keranjang
      shoppingCart.set(productId, quantity);

      return h
        .response({
          message: `${quantity} x ${product.name} has been added/updated in your cart.`,
          cart: Object.fromEntries(shoppingCart) // Tampilkan isi Map untuk debug
        }).code(200);
    },
  },
  {
    method: "POST",
    path: "/cart/item",
    handler: (request, h) => 
    {
      const { productId } = request.payload;
      if (!productId) 
      {
        return h
          .response({ message: "Invalid input. 'productId' is required." })
          .code(400);
      }
      const product = db.products.find((p) => p.id === productId);
      if (!product) 
      {
        return h
          .response({ message: "Product not found" })
          .code(404);
      }
      const currentQty = shoppingCart.get(productId) || 0;
      if (currentQty + 1 > product.stock) 
      {
        return h
          .response({ message: `Insufficient stock for ${product.name}. Only ${product.stock - currentQty} left in cart.` })
          .code(400);
      }
      shoppingCart.set(productId, currentQty + 1);
      return h
        .response({
          message: `${product.name} has been added to your cart (total: ${currentQty + 1}).`,
          cart: Object.fromEntries(shoppingCart)
        }).code(200);
    },
  },
  {
    method: "DELETE",
    path: "/cart/item/{id}",
    handler: (request, h) => 
    {
      const id = parseInt(request.params.id, 10);

      if (shoppingCart.has(id)) 
      {
        shoppingCart.delete(id);
        return h
          .response({
            message: `Product with id ${id} has been removed from the cart.`,
            cart: Object.fromEntries(shoppingCart)
          }).code(200);
      }

      return h
        .response({ message: "Product not found in cart." })
        .code(404);
    },
  },
];

export default routes;