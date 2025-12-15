FROM public.ecr.aws/lambda/nodejs:18

COPY app/ ${LAMBDA_TASK_ROOT}
COPY package.json .

RUN npm install

CMD ["handler.handler"]
