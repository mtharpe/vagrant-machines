#!/bin/bash
echo "Query Web on N1"
dig @n1 -p 8600 web.service.dc1.consul ANY |grep service.dc1.consul. |grep -v DiG |grep -v ';'
echo ""

echo "Query Web on N2"
dig @n2 -p 8600 web.service.dc1.consul ANY |grep service.dc1.consul. |grep -v DiG |grep -v ';'
echo ""

echo "Query Web on N3"
dig @n3 -p 8600 web.service.dc1.consul ANY |grep service.dc1.consul. |grep -v DiG |grep -v ';'
echo ""

echo "Query DB on N1"
dig @n1 -p 8600 db.service.dc1.consul ANY |grep service.dc1.consul. |grep -v DiG |grep -v ';'
echo ""

echo "Quesry DB on N2"
dig @n2 -p 8600 db.service.dc1.consul ANY |grep service.dc1.consul. |grep -v DiG |grep -v ';'
echo ""

echo "Query DB on N3"
dig @n3 -p 8600 db.service.dc1.consul ANY |grep service.dc1.consul. |grep -v DiG |grep -v ';'
echo ""