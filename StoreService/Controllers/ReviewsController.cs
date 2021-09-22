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
    public class ReviewsController : ControllerBase


    {
        private readonly IConfiguration _configuration;
        public ReviewsController(IConfiguration configuration)
        {
            _configuration = configuration;
        }
        [HttpGet("{id}")]
        public ReviewList GetByID(int id)
        {

            ReviewsRepository repository = new ReviewsRepository(_configuration);
            var result = repository.GetReviews(id);

            return result;


        }

    }
}
