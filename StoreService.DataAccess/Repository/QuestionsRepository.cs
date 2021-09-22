using ShopService.DataAccess.Interfaces;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using Dapper;
using System.Runtime.CompilerServices;
using Microsoft.Extensions.Configuration;
using System.Data.SqlClient;
using ShopService.Models;
using ShopService.DataAccess.Models;

namespace ShopService.DataAccess.Repository
{
    public class QuestionsRepository : IQuestions
    {
        private readonly IConfiguration _configuration;

        public QuestionsRepository(IConfiguration configuration)
        {
            _configuration = configuration;
        }
        public  QuestionList GetQuestions(int productID)
        {
            string connectionString = _configuration.GetConnectionString("DefaultConnection");

            using (var connection = new SqlConnection(connectionString))
            {
                connection.Open();

                var result =  connection.Query<Question>("dbo.RetrieveQuestions @ProductID", new { ProductID = productID });
                QuestionList list = new QuestionList();
                list.questionList = new List<Question>();

                foreach (var item in result)
                {
                    Question review = new Question();

                    review.QuestionID = item.QuestionID;
                    review.MainThread = item.MainThread;
                    review.UserName = item.UserName;
                    review.Text = item.Text;
                    list.questionList.Add(review);

                }

                return list;
            }

        }

        public Task<Question> postQuestion(int productID)
        {
            throw new NotImplementedException();
        }
    }
}
