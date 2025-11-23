# app.py do serviço 2
# Serviço que responde no endpoint /processa

from flask import Flask, jsonify
from opentelemetry import trace
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter

# Configuração do provider de traces e exportação para o console
trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)
span_processor = BatchSpanProcessor(ConsoleSpanExporter())
trace.get_tracer_provider().add_span_processor(span_processor)

app = Flask(__name__)
FlaskInstrumentor().instrument_app(app)

@app.route("/processa", methods=["GET"])
def processa():
    with tracer.start_as_current_span("service2-processa"):
        # Simula algum processamento que poderia ser monitorado
        return jsonify({"status": "OK", "msg": "Serviço 2 processou a requisição"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002, debug=True)
