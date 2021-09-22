using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using ShopService.DataAccess.Models;
using ShopService.DataAccess.Repository;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace ShopService.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class CategoryController : ControllerBase
    {
        private readonly IConfiguration configuration;

        public CategoryController(IConfiguration _configuration)
        {
            configuration = _configuration;
        }

        // GET: api/<CategoryController>
        [HttpGet]
        public async Task<CategoryList> Get()
        {
            CategoryRepository categoryRepository = new CategoryRepository(configuration);

            var result = await categoryRepository.RetrieveCategories();
            return result;



        }
    }
}
