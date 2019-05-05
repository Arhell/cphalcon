<?php
declare(strict_types=1);

/**
 * This file is part of the Phalcon Framework.
 *
 * (c) Phalcon Team <team@phalconphp.com>
 *
 * For the full copyright and license information, please view the LICENSE.txt
 * file that was distributed with this source code.
 */

namespace Phalcon\Test\Unit\Cache\AdapterFactory;

use Phalcon\Cache\AdapterFactory;
use Phalcon\Storage\SerializerFactory;
use Phalcon\Test\Fixtures\Cache\Adapter\None;
use UnitTester;

class GetSetHasCest
{
    /**
     * Tests Phalcon\Cache\AdapterFactory :: get()
     *
     * @author Phalcon Team <team@phalconphp.com>
     * @since  2019-05-04
     */
    public function storageAdapterFactoryGetSetHas(UnitTester $I)
    {
        $I->wantToTest('Cache\AdapterFactory - get()/set()/has()');
        $I->skipTest('TODO - Check this');
        $mappers = ['none' => 'Phalcon\Test\Fixtures\Cache\Adapter\None'];
        $factory = new SerializerFactory();
        $service = new AdapterFactory($factory, $mappers);

        $actual = $service->has('unknown');
        $I->assertFalse($actual);

        $actual = $service->has('none');
        $I->assertTrue($actual);

        $actual = $service->has('redis');
        $I->assertTrue($actual);

        $actual = $service->get('none');
        $class  = None::class;
        $I->assertInstanceOf($class, $actual);
    }
}