using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using ShopService.DataAccess;
using ShopService.DataAccess.Models;
using ShopService.DataAccess.Repository;
using ShopService.Models;


namespace ShopService.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class ProductsController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public ProductsController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [HttpGet]
        public async Task<ProductList> Get()
        {
            // Returns the whole ist of products
            ProductsRepository repository = new ProductsRepository(_configuration);
            var result = await repository.getProducts();
            return result;
        }

        [HttpGet("search/{productName}")]
        public async Task<ProductList> GetSearchResults(string productName)
        {
            // Returns products, containing the keyword or product name
            ProductsRepository repository = new ProductsRepository(_configuration);
            var result = await repository.getProductByName(productName);
            return result;
        }

        [HttpGet("category/{id}")]
        public async Task<ProductList> GetByCategoryID(int id)
        {
            // Retruns products, filtered by categories
            ProductsRepository repository = new ProductsRepository(_configuration);
            var result = await repository.getProductByCategory(id);
            return result;
        }

        [HttpGet("{id}")]
        public async Task<Product> GetByID(int id)
        {
            // Returns one specific product, by ID
            ProductsRepository repository = new ProductsRepository(_configuration);
            Product result = await repository.getByID(id);
            return result;
        }

        [HttpGet("browse/{getNextProducts}")]
        public async Task<ProductList> getBrowseProducts(int getNextProducts) 
        {
            ProductsRepository repository = new ProductsRepository(_configuration);
            var result = await repository.getBrowseProducts(getNextProducts);
            return result;
        }
    }
}
