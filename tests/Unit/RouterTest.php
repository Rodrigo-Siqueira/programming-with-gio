<?php

declare(strict_types=1);

namespace Tests\Unit;

use App\Exception\RouteNotFoundException;
use App\Router;
use Override;
use PHPUnit\Framework\TestCase;
use PHPUnit\Framework\Attributes\DataProviderExternal;
use Tests\DataProvider\RouterDataProvider;

class RouterTest extends TestCase
{
    private Router $router;

    #[Override]
    protected function setUp(): void
    {
        parent::setUp();

        $this->router = new Router();
    }

    public function testItRegistersARoute(): void
    {
        $this->router->register('get', '/users', ['users', 'index']);

        $expected = [
            'get' => [
                '/users' => ['users', 'index'],
            ],
        ];

        $this->assertSame($expected, $this->router->routes());
    }

    public function testItRegistersAGetRoute(): void
    {
        $this->router->get('/users', ['users', 'index']);

        $expected = [
            'get' => [
                '/users' => ['users', 'index'],
            ],
        ];

        $this->assertSame($expected, $this->router->routes());
    }

    public function testItRegistersAPostRoute(): void
    {
        $this->router->post('/users', ['users', 'store']);

        $expected = [
            'post' => [
                '/users' => ['users', 'store'],
            ],
        ];

        $this->assertSame($expected, $this->router->routes());
    }

    public function testThereAreNoRoutesWhenRouterIsCreated(): void
    {
        $router = new Router();

        $this->assertEmpty($router->routes());
    }

    #[DataProviderExternal(RouterDataProvider::class, 'routeNotFoundCases')]
    public function testItThrowsRouteNotFoundException(
        string $requestUrl,
        string $requestMethod
    ): void {
        $users = new class() {
            public function delete(): bool
            {
                return true;
            }
        };

        $this->router->get('/users', [$users::class, 'index']);
        $this->router->post('/users', ['users', 'store']);

        $this->expectException(RouteNotFoundException::class);
        $this->router->resolve($requestUrl, $requestMethod);
    }

    public function testItResolvesRouteFromAclosure(): void
    {
        $this->router->get('/users', fn() => [1, 2, 3]);

        $this->assertSame(
            [1, 2, 3],
            $this->router->resolve('/users', 'get'),
        );
    }
}
