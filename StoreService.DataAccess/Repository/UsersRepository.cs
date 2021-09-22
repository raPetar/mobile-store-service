using ShopService.DataAccess.Interfaces;
using ShopService.Models;

using System.Threading.Tasks;
using Dapper;
using Microsoft.Extensions.Configuration;
using System.Data.SqlClient;


namespace ShopService.DataAccess.Repository
{
    public class UsersRepository : IUsers
    {
        private readonly IConfiguration _configuration;


        public UsersRepository(IConfiguration configuration)
        {
            _configuration = configuration;
        }
        public User createUser(string userName, string firstName, string lastName, string phoneNumber, string email, string password)
        {


            string connectionString = _configuration.GetConnectionString("DefaultConnection");
            using (var connection = new SqlConnection(connectionString))
            {
                connection.Open();
                var result =  connection.Query<User>("dbo.RegisterUser @UserName, @Firstname, @LastName, @PhoneNumber, @Email, @Password"
                    , new { UserName = userName, FirstName = firstName, LastName = lastName, PhoneNumber = phoneNumber, Email = email, Password = password });
               
                User user = new User();
                // Assigning values to a user model, from the result 
                foreach (var u in result)
                {
                    user.UserName = userName;
                    user.Password = password;
                    user.FirstName = u.FirstName;
                    user.LastName = u.LastName;
                    user.PhoneNumber = u.PhoneNumber;
                    user.Email = u.Email;  
                }
                return user;
            }
        }

        public async Task<User> updateUser(string userName, string email, string phoneNumber)
        {

            string connectionString = _configuration.GetConnectionString("DefaultConnection");
            using (var connection = new SqlConnection(connectionString))
            {
                connection.Open();

                var result = await connection.QueryAsync<User>("dbo.UpdateUser @UserName,@PhoneNumber, @Email"
                    , new { UserName = userName, PhoneNumber = phoneNumber, Email = email });
              
                User user = new User();
                // Assigning values to a user model, from the result 
                foreach (var u in result)
                {
                    user.UserName = userName;
                    user.Password = u.Password;
                    user.FirstName = u.FirstName;
                    user.LastName = u.LastName;
                    user.PhoneNumber = u.PhoneNumber;
                    user.Email = u.Email;
                }

                return user;
            }
        }

        public async Task<User> validateUser(string userName, string password)
        {
            string connectionString = _configuration.GetConnectionString("DefaultConnection");
            using (var connection = new SqlConnection(connectionString))
            {
                connection.Open();
                var result = await connection.QueryAsync<User>("dbo.ValidateUser  @UserName, @Password",
                    new { UserName = userName, Password = password });

                User user = new User();
                foreach (var u in result)
                {
                    user.UserName = userName;
                    user.Password = password;
                    user.FirstName = u.FirstName;
                    user.LastName = u.LastName;
                    user.PhoneNumber = u.PhoneNumber;
                    user.Email = u.Email;
                }
                return user;
            }
        }
    }
}
