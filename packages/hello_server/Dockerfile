FROM dart:stable AS build

WORKDIR /app

COPY . .
RUN dart pub get
RUN dart pub run build_runner build -d
RUN dart compile exe bin/server.dart -o bin/server

FROM scratch

COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/

EXPOSE 8080
ENTRYPOINT ["/app/bin/server"]
