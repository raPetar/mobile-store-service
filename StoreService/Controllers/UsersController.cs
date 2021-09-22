using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using ShopService.DataAccess.Repository;
using ShopService.Models;


namespace ShopService.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public UsersController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [HttpPost("register")]
        public User PostRegister([FromBody] User user)
        {
            // Handles Post requests for registering a new user
            // calls the createUser method from the UsersRepository
            UsersRepository repository = new UsersRepository(_configuration);
            User result = repository.createUser(user.UserName, user.FirstName, user.LastName, user.PhoneNumber, user.Email, user.Password);
            return result;
        }

        [HttpPost("login")]
        public async Task<User> PostLogin([FromBody] User user)
        {
            // Handles Post requests for logins
            // calls the validateUser method from the UsersRepository
            UsersRepository repository = new UsersRepository(_configuration);
            User result = await repository.validateUser(user.UserName, user.Password);
            return result;
        }

        [HttpPost("update")]
        public async Task<User> UpdateUser([FromBody] User user) 
        {
            // Handles Post requests for updates regarding a user
            // calls the updateUser method from the UsersRepository
            UsersRepository repository = new UsersRepository(_configuration);
            User result = await repository.updateUser(user.UserName, user.Email, user.PhoneNumber);
            return result;
        }
    }
}
