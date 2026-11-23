# MongoDB for PipesHub, pinned by version and digest.
# 7.0 instead of 8.0: MongoDB 8.0.x exits at startup on Linux kernels 6.19 through 7.0.13
# (SERVER-121912 / SERVER-125742), and some Railway hosts run those kernels. 7.0 runs on all of them.
FROM mongo:7.0.48@sha256:41e8195b2791692695e1dc9bd21cd51d0a3af05fff8ace9304a5c1acf94f1ae1
COPY --chmod=755 start.sh /usr/local/bin/railway-mongo-start.sh
CMD ["/usr/local/bin/railway-mongo-start.sh"]
