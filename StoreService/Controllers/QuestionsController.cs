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
    public class QuestionsController : ControllerBase
    {

        private readonly IConfiguration _configuration;

        public QuestionsController(IConfiguration configuration)
        {
            _configuration = configuration;
        }
    
        [HttpGet("{id}")]
        public  QuestionList GetByID(int id)
        {

            QuestionsRepository repository = new QuestionsRepository(_configuration);
            var result =  repository.GetQuestions(id);

            return result;


        }

        // POST api/<ReviewsController>
        [HttpPost]
        public void Post([FromBody] string value)
        {
        }

        [HttpPut("{id}")]
        public void Put(int id, [FromBody] string value)
        {
        }

        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }
    }
}
