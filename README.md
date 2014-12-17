About
=====
Пока довольно простой инструмент для проверки html-верстки. Уже сейчас умеет процедуры, foreach и набор готовых проверок, возможен reuse написанных тестов. Инструмент будет развиватся и далее.

Отличительная особенность - для написантя тестов не нужно знать языков программирования, достаточно знать XML и понимать чего хочешь. Удобно для тестировщиков и любителей "не кодить, когда не надо".

Сам инструмент написан на ruby, что делает его разработку и развитие максимально простым и удобным. Для разбра xml и html используется Nokogiri - рекордсмен по скорости парсинга. 

Ждем pull request-ов :-)

Installation on Debian
======================

    apt-get install ruby
    gem install nokogiri

Usage
=====

1. Make XML file with your Test-Plan (for example, checklist.xml)
2. run:```./xwebck --test=checklist.xml --urlbase=https://github.com/```

3. Check Exit code and console output

Integration with CI
===================

В CI достаточно проверять exit code процесса xwebck для получения результата pass/fail всего теста. Для вывода только ошибок можно перенаправлять вывод в grep, например так:

    ./xwebck --test=checklist.xml --urlbase=https://github.com/ | grep FAIL

Будут выведены только упавшие проверки.



