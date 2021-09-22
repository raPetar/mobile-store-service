using ShopService.Models;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace ShopService.DataAccess.Interfaces
{
    public interface IUsers
    {
        User createUser(string userName, string firstName, string lastName, string phoneNumber, string email, string password);
        Task<User> validateUser(string userName, string password);
        Task<User> updateUser(string userName, string email, string phoneNUmber);
    }
}
