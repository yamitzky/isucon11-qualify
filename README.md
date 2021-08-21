# isucon11-qualify

## 立ち上げ方

mysql につなげるようにするため

```
ssh isucon@35.76.156.15 -g -N -f -L 3306:localhost:3306
```

環境変数に

```
POST_ISUCONDITION_TARGET_BASE_URL=http://127.0.0.1:5000
```

を入れる。もしモックサーバー必要であれば

```
ssh isucon@35.76.156.15 -g -N -f -L 5000:localhost:5000
```
