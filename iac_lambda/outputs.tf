output "lambda_function_name" {
  description = "Nome da função Lambda"
  value       = aws_lambda_function.ppeks_health.function_name
}

output "lambda_function_url" {
  description = "URL HTTP da função Lambda (aplicação web)"
  value       = aws_lambda_function_url.ppeks_health_url.function_url
}

output "lambda_arn" {
  description = "ARN da função Lambda"
  value       = aws_lambda_function.ppeks_health.arn
}
