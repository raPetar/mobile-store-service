using Dapper;
using Microsoft.Extensions.Configuration;
using ShopService.DataAccess.Interfaces;
using ShopService.DataAccess.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace ShopService.DataAccess.Repository
{
    public class ReviewsRepository : IReviews
    {

        private readonly IConfiguration _configuration;

        public ReviewsRepository(IConfiguration configuration)
        {
            _configuration = configuration;
        }
        public ReviewList GetReviews(int productID)
        {
            string connectionString = _configuration.GetConnectionString("DefaultConnection");

            using (var connection = new SqlConnection(connectionString))
            {
                connection.Open();
                var result = connection.Query<Review>("dbo.RetrieveReviews @ProductID", new { ProductID = productID });
                ReviewList list = new ReviewList();
                list.reviewList = new List<Review>();

                foreach (var item in result)
                {
                    Review review = new Review();

                    review.ReviewID = item.ReviewID;
                    review.MainThread = item.MainThread;
                    review.UserName = item.UserName;
                    review.Text = item.Text;
                    list.reviewList.Add(review);
                }
                return list;
            }
        }
    }
}

