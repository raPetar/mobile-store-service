using Microsoft.Extensions.Configuration;
using ShopService.DataAccess.Interfaces;
using ShopService.DataAccess.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;
using Dapper;

namespace ShopService.DataAccess.Repository
{
    public class CategoryRepository : ICategory
    {
        private readonly IConfiguration configuration;

        public CategoryRepository(IConfiguration _configuration)
        {
            configuration = _configuration;
        }

        public async Task<CategoryList> RetrieveCategories()
        {
            string connectionString = configuration.GetConnectionString("DefaultConnection");
            using (var connection = new SqlConnection(connectionString))
            {
                var result = await connection.QueryAsync<Category>("dbo.RetrieveCategories");
                CategoryList category = new CategoryList();
                category.categoryList = new List<Category>();

                foreach (var item in result)
                {

                    Category c = new Category();
                    c.CategoryID = item.CategoryID;
                    c.Name = item.Name;
                    category.categoryList.Add(c);
                }
                return category;
            }
        }
    }
}
