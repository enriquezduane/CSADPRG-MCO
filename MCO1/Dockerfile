FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    ruby \
    golang \
    openjdk-11-jdk \
    curl \
    zip

RUN curl -s https://get.sdkman.io | bash
RUN bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && sdk install kotlin"

WORKDIR /app

COPY loan.rb .
COPY loanCalculator.kt .
COPY loanCalculatorGo.go .

# Make sure the files are executable
RUN chmod +x loan.rb
