# app.py do serviço 1
# Serviço expõe endpoint /aciona que chama o serviço2 e retorna resposta

import requests
from flask import Flask, jsonify
from opentelemetry import trace
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter

# Configuração do provedor de traces e exportação para o console
trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)
span_processor = BatchSpanProcessor(ConsoleSpanExporter())
trace.get_tracer_provider().add_span_processor(span_processor)

app = Flask(__name__)
FlaskInstrumentor().instrument_app(app)
RequestsInstrumentor().instrument()

@app.route('/aciona', methods=['GET'])
def aciona():
    # Gera span local antes de chamar serviço 2
    with tracer.start_as_current_span("service1-aciona"):
        resposta = requests.get("http://service2:5002/processa")
        conteudo = resposta.json()
        return jsonify({"msg": "Serviço 1 acionou o Serviço 2", "resposta_2": conteudo}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)
